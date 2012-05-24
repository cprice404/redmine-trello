require 'trello'

module TrelloUtils
  include Trello::Authorization

  # A simple utility function for initializing authentication / authorization for the Trello REST API
  #
  # @param [String] the Trello App Key (can be retrieved from https://trello.com/1/appKey/generate)
  # @param [String] the Trello "secret" (can be retrieved from https://trello.com/1/appKey/generate)
  # @param [String] the Trello user token (can be generated with various expiration dates and
  #   permissions via instructions at https://trello.com/docs/gettingstarted/index.html#getting-a-token-from-a-user)
  def self.initialize_auth(app_key, secret, user_token)

    Trello::Authorization.const_set :AuthPolicy, OAuthPolicy

    OAuthPolicy.consumer_credential = OAuthCredential.new(app_key, secret)

    OAuthPolicy.token = OAuthCredential.new(user_token)

  end
end