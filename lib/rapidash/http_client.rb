require 'faraday'
require 'faraday_middleware'
require 'faraday_middleware/multi_json'

module Rapidash
  module HTTPClient
    attr_accessor :login, :password
    attr_writer :connection

    def initialize(options = {})
      [:login, :password].each do |key|
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
      url = connection.build_url(normalize_url(url), options[:params]).to_s
      response = connection.run_request(verb, url, options[:body], options[:header])

      response.body
    end
  end
end
