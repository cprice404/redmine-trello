require 'trello'

module TrelloUtils
  include Trello::Authorization

  def self.initialize_auth(app_key, secret, user_token)

    Trello::Authorization.const_set :AuthPolicy, OAuthPolicy

    OAuthPolicy.consumer_credential = OAuthCredential.new(app_key, secret)

    OAuthPolicy.token = OAuthCredential.new(user_token)

  end
end