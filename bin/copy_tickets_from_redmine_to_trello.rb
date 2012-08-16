#!/usr/bin/env ruby

$LOAD_PATH << File.join(File.absolute_path(File.dirname(__FILE__)), "..", "config")
$LOAD_PATH << File.join(File.absolute_path(File.dirname(__FILE__)), "..", "lib")

require 'rmt/config'
require 'redmine_trello_conf'
require 'rmt/redmine'
require 'rmt/trello'

def card_for(issue)
  id = issue[:id]
  proc { |card| card.name =~ /\(#{id}\)/ }
end

def issue_for(card)
  if card.name =~ /\((\d+)\)/
    id = $1
    proc { |issue| issue[:id] =~ /#{id}/ }
  else
    raise "Unable to parse card name for ticket id: #{card.name}"
  end
end

mappings = RMT::Config.mappings

trello_list_issues = mappings.inject({}) do |issue_buckets, mapping|
  issues = (issue_buckets[mapping.trello] ||= [])
  redmine_client = RMT::Redmine.new(mapping.redmine.base_url,
                                    mapping.redmine.username,
                                    mapping.redmine.password)
  issues.concat(redmine_client.get_issues_for_project(mapping.redmine.project_id, :status => RMT::Redmine::Status::Unreviewed))
  issue_buckets
end

trello_list_issues.each do |list, issues|
  trello = RMT::Trello.new(list.app_key,
                           list.secret,
                           list.user_token)

  existing_cards = trello.list_cards_in(list.target_list_id)

  existing_cards.reject do |card|
    issues.any? &issue_for(card)
  end.each do |card|
    puts "Removing card: #{card.name}"
    trello.archive_card(card)
  end

  issues.reject do |issue|
    existing_cards.any? &card_for(issue)
  end.each do |issue|
      puts "Adding issue: #{issue[:id]}: #{issue[:subject]}"
      trello.create_card(:name => "(#{issue[:id]}) #{issue[:subject]}",
                         :list => list.target_list_id,
                         :description => issue[:description],
                         :color => list.color_map[issue[:tracker]])
  end
end
