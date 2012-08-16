#!/usr/bin/env ruby

$LOAD_PATH << File.join(File.absolute_path(File.dirname(__FILE__)), "..", "config")
$LOAD_PATH << File.join(File.absolute_path(File.dirname(__FILE__)), "..", "lib")

#
# This is a command-line program that will read the redmine_trello_conf.rb config file,
# find unreviewed issues on the specified redmine project, and create cards for them on the
# specified Trello list. If a card appears in the Trello list that does not appear in the
# unreviewed tickets, then the card will be removed from the list.
#
# Multiple mappings from redmine projects to Trello lists can be setup in the redmine_trello_conf.rb
# file. The mappings are allowed to point to the same Trello list, as well.
#

require 'rmt/config'
require 'redmine_trello_conf'
require 'rmt/redmine'
require 'rmt/synchronize'
require 'rmt/synchronization_data'


RMT::Config.
  mappings.
  inject(RMT::Synchronize.new) do |sync, mapping|
    redmine_client = RMT::Redmine.new(mapping.redmine.base_url,
                                      mapping.redmine.username,
                                      mapping.redmine.password)

    redmine_issues = redmine_client.get_issues_for_project(mapping.redmine.project_id, :status => RMT::Redmine::Status::Unreviewed)

    sync.synchronize(redmine_issues.collect(&RMT::SynchronizationData.from_redmine(mapping.trello)),
                     mapping.trello)
  end.
  finish
