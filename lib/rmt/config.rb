require 'rmt/redmine_source'
require 'rmt/github_source'

module RMT
  class Config
    @mappings = []

    def self.define(name, &definition)
      @mappings << DataToTrelloMapping.new(name, definition)
    end

    def self.mappings
      @mappings
    end

    class DataToTrelloMapping
      attr_reader :redmine, :trello, :name

      def initialize(name, definition)
        instance_eval(&definition)
        @name = name
      end

      def from_redmine(config)
        raise "Cannot define two sources at once!" if @github
        @redmine = RedmineConfig.new(config)
      end

      def from_github(config)
        raise "Cannot define two sources at once!" if @redmine
        @github = GithubConfig.new(config)
      end

      def to_trello(config)
        @trello = TrelloConfig.new(config)
      end

      def source
        if @redmine
          return RMT::RedmineSource.new(@redmine)
        end

        if @github
          return RMT::GithubSource.new(@github)
        end

        raise "No sources defined!"
      end
    end

    class RedmineConfig
      attr_reader :base_url, :username, :password, :project_id

      def initialize(definition)
        @base_url = definition[:base_url]
        @username = definition[:username]
        @password = definition[:password]
        @project_id = definition[:project_id]
      end
    end

    class GithubConfig
      attr_reader :user, :repo, :oauth_token

      def initialize(definition)
        @user = definition[:user]
        @repo = definition[:repo]
        @oauth_token = definition[:oauth_token]
      end
    end

    class TrelloConfig
      attr_accessor :app_key, :secret, :user_token, :target_list_id, :color_map

      def initialize(definition)
        @app_key = definition[:app_key]
        @secret = definition[:secret]
        @user_token = definition[:user_token]
        @target_list_id = definition[:target_list_id]
        @color_map = definition[:color_map]
      end

      def eql?(other)
        @target_list_id.eql?(other.target_list_id)
      end

      def hash
        @target_list_id.hash
      end
    end
  end
end
