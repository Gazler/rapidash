require 'faraday'
require 'faraday_middleware'

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
        builder.request self.class.encode_post_data_with

        builder.use Faraday::Request::BasicAuthentication, login, password

        if self.class.respond_to?(:raise_error) && self.class.raise_error
          builder.use Faraday::Response::RaiseRapidashError
        end

        builder.use FaradayMiddleware::FollowRedirects
        builder.use FaradayMiddleware::Mashify

        builder.use FaradayMiddleware::ParseJson, :content_type => /\bjson$/
        builder.use FaradayMiddleware::ParseXml, :content_type => /\bxml$/

        builder.adapter :net_http
      end
    end

    def request(verb, url, options = {})
      url = connection.build_url(normalize_url(url), options[:params]).to_s
      response = connection.run_request(verb, url, options[:body], options[:header])

      response.body
    end
  end
end
