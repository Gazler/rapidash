require 'faraday'

module Rapidash
  module HTTPClient

    attr_accessor :site, :extension
    attr_writer :connection

    def site=(value)
      @connection = nil
      @site = value
    end

    def connection
      @connection ||= Faraday.new(site)
    end

    def request(verb, url, options = {})
      url = "#{url}.#{extension}" if extension
      url = connection.build_url(url, options[:params]).to_s
      response = connection.run_request(verb, url, options[:body], options[:header])

      # "foo"[0] does not work in 1.8.7, "foo"[0,1] is required
      case response.status.to_s[0,1]
      #Handle redirects
      when "3"
        request(verb, response.headers["location"], options)
      when "2"
        return Response.new(response)
      end
    end
  end
end
