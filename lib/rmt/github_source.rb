require 'github_api'
require 'rmt/synchronization_data'

module RMT
  class GithubSource
    def initialize(github_config)
      @github = Github.new
      @config = github_config
    end

    def data_for(trello)
      target_list = trello.target_list_id
      pull_requests = @github.pull_requests.all(@config.user, @config.repo, :per_page => 100)
      pull_requests.collect do |pr|
        RMT::SynchronizationData.new("PR #{@config.repo}/#{pr.number}",
                                     pr.title,
                                     pr.body,
                                     target_list,
                                     "blue",
                                     proc { |trello| trello.all_cards_on_board_of(target_list) })
      end
    end
  end
end
