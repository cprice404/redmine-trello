#!/usr/bin/env ruby

$LOAD_PATH << File.join(File.absolute_path(File.dirname(__FILE__)), "..", "config")
$LOAD_PATH << File.join(File.absolute_path(File.dirname(__FILE__)), "..", "lib")

require 'redmine_trello_conf'
require 'redmine_client'
require 'trello_utils'

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
    @last_run_file = File.join(@state_dir, "last_run.txt")

    unless (File.directory?(@state_dir))
      Dir.mkdir(@state_dir)
    end
  end

  def add_issue_to_trello(issue)
    card = Trello::Card.create(:name => "(#{issue[:id]}) #{issue[:subject]}",
                        :list_id => RMTConfig::Trello::TargetListId,
                        :description => sanitize_utf8(issue[:description]))
    color = RMTConfig::Redmine::TrackerToTrelloLabelColorMap[issue[:tracker]]
    if color
      card.add_label(color)
    end
  end

	def sanitize_utf8(str)
	  str.each_char.map { |c| c.valid_encoding? ? c : "\ufffd"}.join
	end

  def get_last_run_info()

    begin
      return File.open(@last_run_file, "r") do |file|
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

  def save_last_run_info(max_ticket_id)
    File.open(@last_run_file, "w") do |file|
      file.puts(Time.new().strftime(DateFormat))
      file.puts(max_ticket_id)
    end
  end

  def main()
    puts "Beginning run (#{Time.new})"

    redmine_client = RedmineClient.new(RMTConfig::Redmine::BaseUrl,
                                       RMTConfig::Redmine::Username,
                                       RMTConfig::Redmine::Password)

    last_run_date, last_ticket_id = get_last_run_info()
    new_max_ticket_id = last_ticket_id

    issues = redmine_client.get_issues_for_project(RMTConfig::Redmine::ProjectId,
                                                   :created_date_range => [last_run_date, nil])

    TrelloUtils.initialize_auth(RMTConfig::Trello::AppKey,
                                RMTConfig::Trello::Secret,
                                RMTConfig::Trello::UserToken)

    issues.each do |issue|
      issue_id = Integer(issue[:id])
      if issue_id > last_ticket_id
        puts "Adding issue: #{issue_id}: #{issue[:subject]}"
        add_issue_to_trello(issue)
        if (issue_id > new_max_ticket_id)
          new_max_ticket_id = issue_id
        end
      else
        puts "Skipping issue #{issue_id} because it has already been added."
      end
    end

    save_last_run_info(new_max_ticket_id)

    puts ""
  end
end

RedmineToTrello.new().main()

