require 'faraday'

module Rapidash
  module HTTPClient

    def self.included(base)
      base.extend(ClassMethods)
    end

    attr_accessor :extension, :site, :login, :password
    attr_writer :connection

    def initialize(options = {})
      [:login, :password].each do |key|
        self.send("#{key.to_s}=".to_sym, options[key])
      end
    end

    def site=(site)
      @site = site
      @connection = nil
    end

    def connection
      @connection ||= Faraday.new(site || self.class.site_url)
    end

    def request(verb, url, options = {})
      if extension
        url = "#{url}.#{(extension)}"
      elsif self.class.respond_to?(:url_extension) && self.class.url_extension
        url = "#{url}.#{(self.class.url_extension)}"
      end
      url = connection.build_url(url, options[:params]).to_s
      response = connection.run_request verb, url, options[:body], options[:header] do |request|
        request.headers.update(:Authorization => connection.basic_auth(login, password)) if login && password
      end

      # "foo"[0] does not work in 1.8.7, "foo"[0,1] is required
      case response.status.to_s[0,1]
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



    module ClassMethods
      attr_accessor :site_url

      def site(site)
        @site_url = site
      end
    end
  end
end
