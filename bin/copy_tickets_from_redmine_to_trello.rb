#!/usr/bin/env ruby

$LOAD_PATH << File.join(File.absolute_path(File.dirname(__FILE__)), "..", "config")
$LOAD_PATH << File.join(File.absolute_path(File.dirname(__FILE__)), "..", "lib")

require 'redmine_trello_conf'
require 'redmine_client'
require 'trello_utils'

redmine_client = RedmineClient.new(RMTConfig::Redmine::BaseUrl,
                                   RMTConfig::Redmine::Username,
                                   RMTConfig::Redmine::Password)

# TODO: make this date range into a command-line arg
issues = redmine_client.get_issues_for_project(RMTConfig::Redmine::ProjectId,
    :created_date_range => ["2012-05-21", nil])


TrelloUtils.initialize_auth(RMTConfig::Trello::AppKey,
                            RMTConfig::Trello::Secret,
                            RMTConfig::Trello::UserToken)

issues.each do |issue|
  # TODO: filter out issues based on status
  card = Trello::Card.create(:name => "(#{issue[:id]}) #{issue[:subject]}",
                      :list_id => RMTConfig::Trello::TargetListId,
                      :description => issue[:description])
  color = RMTConfig::Redmine::TrackerToTrelloLabelColorMap[issue[:tracker]]
  if color
    card.add_label(color)
  end
end
