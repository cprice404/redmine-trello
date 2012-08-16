require 'github_api'
require 'rmt/synchronization_data'

module RMT
  class GithubSource
    def initialize(github_config)
      @github = Github.new
      @config = github_config
    end

    def data_for(trello)
      pull_requests = @github.pull_requests.all(@config.user, @config.repo, :per_page => 100)
      pull_requests.collect do |pr|
        RMT::SynchronizationData.new("PR #{pr.number}", pr.title, pr.body, trello.target_list_id, "blue")
      end
    end
  end
end
