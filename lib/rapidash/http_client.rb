require 'faraday'

module Rapidash
  module HTTPClient

    attr_accessor :site
    attr_writer :connection

    def site=(value)
      @connection = nil
      @site = value
    end

    def connection
      @connection ||= Faraday.new(site)
    end

    def get(url, options = {})
      request(:get, url, options)
    end

    def post(url, options = {})
      request(:post, url, options)
    end

    def request(verb, url, options = {})
      url = connection.build_url(url, options[:params]).to_s
      response = connection.run_request(verb, url, options[:body], options[:header])

      case response.status.to_s[0]
      #Handle redirects
      when "3"
        request(verb, response.headers["location"], options)
      when "2"
        return Response.new(response)
      end
    end
  end
end
