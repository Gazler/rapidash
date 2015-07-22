require 'faraday'
require 'faraday_middleware'
require 'faraday_middleware/multi_json'

module Rapidash
  module HTTPClient
    attr_accessor :login, :password, :request_default_options
    attr_writer :connection

    # Provide login and password fields for basic HTTP authentication
    # Provide request_default_options field for default options to be provided on each http request
    # To set a default User-agent which identifies your application, provide
    # { request_default_options: { header: { user_agent: 'My great new App V.0.1   Contact: me@me.com'} } }
    def initialize(options = {})
      [:login, :password, :request_default_options].each do |key|
        self.send("#{key.to_s}=".to_sym, options[key])
      end
    end

    def connection
      raise ConfigurationError.new "Site is required" unless site

      @connection ||= Faraday.new(site) do |builder|
        if login || password
          builder.use Faraday::Request::BasicAuthentication, login, password
        end

        connection_builder.call(builder)
      end
    end

    def request(verb, url, options = {})
      options.merge!(self.request_default_options) if self.request_default_options
      url = connection.build_url(normalize_url(url), options[:params]).to_s
      response = connection.run_request(verb, url, options[:body], options[:header])

      response.body
    end
  end
end
