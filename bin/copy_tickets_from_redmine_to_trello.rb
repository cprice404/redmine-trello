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
require 'rmt/trello'
require 'rmt/synchronization_data'


class Synchronize
  def initialize
    @trello_list_data = {}
  end

  def synchronize(data, to_trello)
    list_data = (@trello_list_data[to_trello] ||= [])
    list_data.concat(data)
    self
  end

  def finish
    @trello_list_data.each do |list, data|
      trello = RMT::Trello.new(list.app_key,
                               list.secret,
                               list.user_token)

      existing_cards = trello.list_cards_in(list.target_list_id)

      existing_cards.
        reject { |card| data.any? { |data| data.is_data_for? card } }.
        each do |card|
          puts "Removing card: #{card.name}"
          trello.archive_card(card)
        end

      data.
        reject { |data| existing_cards.any? { |card| data.is_data_for? card } }.
        each { |data| data.insert_into(trello) }
    end
  end
end

RMT::Config.
  mappings.
  inject(Synchronize.new) do |sync, mapping|
    redmine_client = RMT::Redmine.new(mapping.redmine.base_url,
                                      mapping.redmine.username,
                                      mapping.redmine.password)

    redmine_issues = redmine_client.get_issues_for_project(mapping.redmine.project_id, :status => RMT::Redmine::Status::Unreviewed)

    sync.synchronize(redmine_issues.collect(&RMT::SynchronizationData.from_redmine(mapping.trello)),
                     mapping.trello)
  end.
  finish
