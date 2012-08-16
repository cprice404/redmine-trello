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
      issues = @redmine_client.get_issues_for_project(@project_id, :status => RMT::Redmine::Status::Unreviewed)
      issues.collect(&RMT::SynchronizationData.from_redmine(trello))
    end
  end
end
