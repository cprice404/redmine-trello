#!/usr/bin/env ruby

$LOAD_PATH << File.join(File.absolute_path(File.dirname(__FILE__)), "..", "config")
$LOAD_PATH << File.join(File.absolute_path(File.dirname(__FILE__)), "..", "lib")

require 'rmt/config'
require 'redmine_trello_conf'
require 'rmt/redmine'
require 'rmt/trello'

#
# This is a command-line program that will read the redmine_trello_conf.rb config file,
# find recent issues on the specified redmine project, and create cards for them on the
# specified Trello list.
#
# It writes a state file in "../state" that keeps track of the last date that it was run
# and the last ticket ID that it created a card for; this allows the script to be
# run as a cron job at whatever desired interval and be smart enough to avoid creating
# duplicates of cards that it has already created.
#

class RedmineToTrello

  DateFormat = "%Y-%m-%d"

  def initialize()
    @state_dir = File.join(File.absolute_path(File.dirname(__FILE__)), "..", "state")
    unless (File.directory?(@state_dir))
      Dir.mkdir(@state_dir)
    end
  end

	def last_run_file(mapping)
    File.join(@state_dir, "last_run_#{mapping.name}.txt")
	end

  def add_issue_to(trello, issue, trello_config)
    trello.create_card(:name => "(#{issue[:id]}) #{issue[:subject]}",
                       :list => trello_config.target_list_id,
                       :description => issue[:description],
                       :color => trello_config.color_map[issue[:tracker]])
  end

  def get_last_run_info(mapping)
    begin
      return File.open(last_run_file(mapping), "r") do |file|
        last_run_date = file.readline().strip()
        last_ticket_id = Integer(file.readline().strip())
        [last_run_date, last_ticket_id]
      end
    rescue Errno::ENOENT => e
      # the state file doesn't exist, so we'll return some usable sentinel values that will
      #  cause all tickets to get selected
      return ["2012-01-01", 0]
    end
  end

  def save_last_run_info(max_ticket_id, mapping)
    File.open(last_run_file(mapping), "w") do |file|
      file.puts(Time.new().strftime(DateFormat))
      file.puts(max_ticket_id)
    end
  end

  def main(mappings)
		mappings.each do |mapping|
			puts "Beginning run (#{Time.new})"

			redmine_client = RedmineClient.new(mapping.redmine.base_url,
																				 mapping.redmine.username,
																				 mapping.redmine.password)

			last_run_date, last_ticket_id = get_last_run_info(mapping)
			new_max_ticket_id = last_ticket_id

			issues = redmine_client.get_issues_for_project(mapping.redmine.project_id,
																										 :created_date_range => [last_run_date, nil])

			trello = RMT::Trello.new(mapping.trello.app_key,
											         mapping.trello.secret,
															 mapping.trello.user_token)

			issues.each do |issue|
				issue_id = Integer(issue[:id])
				if issue_id > last_ticket_id
					puts "Adding issue: #{issue_id}: #{issue[:subject]}"
					add_issue_to_trello(issue, mapping.trello)
					if (issue_id > new_max_ticket_id)
						new_max_ticket_id = issue_id
					end
				else
					puts "Skipping issue #{issue_id} because it has already been added."
				end
			end

			save_last_run_info(new_max_ticket_id, mapping)

			puts ""
		end
  end
end

RedmineToTrello.new().main(RMT::Config.mappings)
