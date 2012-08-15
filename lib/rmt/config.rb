module RMT
  class Config
    @mappings = []

    def self.define(name, &definition)
      @mappings << RedmineToTrelloMapping.new(name, definition)
    end

    def self.mappings
      @mappings
    end

    class RedmineToTrelloMapping
      attr_reader :redmine, :trello, :name

      def initialize(name, definition)
        instance_eval(&definition)
        @name = name
      end

      def from_redmine(config)
        @redmine = RedmineConfig.new(config)
      end

      def to_trello(config)
        @trello = TrelloConfig.new(config)
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

    class TrelloConfig
      attr_accessor :app_key, :secret, :user_token, :target_list_id, :color_map

      def initialize(definition)
        @app_key = definition[:app_key]
        @secret = definition[:secret]
        @user_token = definition[:user_token]
        @target_list_id = definition[:target_list_id]
        @color_map = definition[:color_map]
      end
    end
  end
end
