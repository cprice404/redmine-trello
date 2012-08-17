require 'rmt/redmine'
require 'rmt/synchronization_data'

module RMT
  class RedmineSource
    def initialize(redmine_config)
      @redmine_client = RMT::Redmine.new(redmine_config.base_url,
                                         redmine_config.username,
                                         redmine_config.password)
      @project_id = redmine_config.project_id
    end

    def data_for(trello)
      target_list = trello.target_list_id
      issues = @redmine_client.get_issues_for_project(@project_id, :status => RMT::Redmine::Status::Unreviewed)
      issues.collect { |ticket| SynchronizationData.new(ticket[:id],
                                                        ticket[:subject],
                                                        ticket[:description],
                                                        target_list,
                                                        trello.color_map[ticket[:tracker]],
                                                        proc { |trello| trello.list_cards_in(target_list) }) }
    end
  end
end
