require 'faraday'

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
      @connection ||= Faraday.new(site)
    end

    def request(verb, url, options = {})
      url = connection.build_url(normalize_url(url), options[:params]).to_s
      response = connection.run_request verb, url, options[:body], options[:header] do |request|
        request.headers.update(:Authorization => connection.basic_auth(login, password)) if login && password
      end

      processing_response response, verb, options
    end

    def processing_response response, verb, options
      # "foo"[0] does not work in 1.8.7, "foo"[0,1] is required
      case response.status.to_s[0, 1]
        when "5", "4"
          error = ResponseError.new(response)
          raise error if self.class.respond_to?(:raise_error) && self.class.raise_error
          return nil
        #Handle redirects
        when "3"
          request(verb, response.headers["location"], options)
        when "2"
          return Response.new(response)
      end
    end
  end
end
