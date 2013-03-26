require 'rmt/redmine'
require 'rmt/synchronization_data'

module RMT
  class RedmineSource
    def initialize(redmine_config)
      @redmine_client = RMT::Redmine.new(redmine_config.base_url,
                                         redmine_config.username,
                                         redmine_config.password)
      @project_id = redmine_config.project_id
      @check_all_lists = !! redmine_config.check_all_lists
    end

    def data_for(trello)
      target_list = trello.target_list_id
      issues = @redmine_client.get_issues_for_project(
        @project_id,
        :status => RMT::Redmine::Status::Unreviewed
      )
      relevant_cards_loader =
        if @check_all_lists
          proc { |trello| trello.all_cards_on_board_of(target_list) }
        else
          proc { |trello| trello.list_cards_in(target_list) }
        end
      issues.collect do |ticket|
        SynchronizationData.new(
          ticket[:id],
          ticket[:subject],
          ticket[:description],
          target_list,
          trello.color_map[ticket[:tracker]],
          relevant_cards_loader
        )
      end
    end
  end
end

