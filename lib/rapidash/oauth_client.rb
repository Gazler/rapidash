require 'oauth2'
require 'hashie'

module Rapidash
  module OAuthClient
    attr_accessor :secret, :uid, :access_token, :site

    def initialize(options)
      [:uid, :secret, :site].each do |key|
        if options[key]
          self.send("#{key.to_s}=".to_sym, options[key])
        else
          unless self.class.respond_to?(key) && send(key)
            raise ConfigurationError.new "Missing #{key} value"
          end
        end
      end

      self.access_token = options[:access_token] if options[:access_token]
    end

    def request(verb, url, options = {})
      url = normalize_url(url)
      options[:body] = options[:body].to_json if options[:body]
      options[:raise_errors] = self.class.respond_to?(:raise_error) && self.class.raise_error
      response = oauth_access_token.send(verb.to_sym, "#{site}/#{url}", options)

      response.body
    end

    def access_token_from_code(code, url)
      token = client.auth_code.get_token(code, :redirect_uri => url)
      self.access_token = token.token
    end

    private

    def client
      @oauth_client ||= ::OAuth2::Client.new(uid, secret, :site => site, :connection_build => connection_builder)
    end

    def oauth_access_token
      @oauth_access_token ||= ::OAuth2::AccessToken.new(client, access_token)
    end
  end
end

