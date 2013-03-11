require 'oauth2'
require 'hashie'

module Rapidash
  module OAuthClient

    attr_accessor :secret, :uid, :access_token, :site, :extension

    def initialize(options)
      [:uid, :secret, :site].each do |key|
        if options[key]
          self.send("#{key.to_s}=".to_sym, options[key])
        else
          raise ConfigurationError.new "Missing #{key} value" 
        end
      end
      self.access_token = options[:access_token] if options[:access_token]
    end

    def request(verb, url, options = {})
      if extension
        url = "#{url}.#{(extension)}"
      elsif self.class.respond_to?(:url_extension) && self.class.url_extension
        url = "#{url}.#{(self.class.url_extension)}"
      end
        options[:raise_errors] = self.class.respond_to?(:raise_error) && self.class.raise_error
      response = oauth_access_token.send(verb.to_sym, "#{site}/#{url}", options)
      return Response.new(response)
    end

    def access_token_from_code(code, url)
      token = client.auth_code.get_token(code, :redirect_uri => url)
      self.access_token = token.token
    end

    private

    def client
      @oauth_client ||= ::OAuth2::Client.new(uid, secret, :site => site) 
    end

    def oauth_access_token
      @oauth_access_token ||= ::OAuth2::AccessToken.new(client, access_token)
    end
  end
end

