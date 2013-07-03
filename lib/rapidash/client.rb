module Rapidash
  class Client
    include Resourceable

    attr_accessor :extension

    def initialize
      raise ConfigurationError.new "Missing Method, define using `method` on your client"
    end

    class << self
      attr_accessor :patch, :raise_error, :extension, :encoder

      def method(method)
        case method
        when :http then include HTTPClient
        when :oauth then include OAuthClient
        when :test then include TestClient
        else
          raise ConfigurationError.new "Invalid API Authentication Method"
        end
      end

      def use_patch
        @patch = true
      end

      def extension(extension = nil)
        @extension ||= extension
      end

      def site(site = nil)
        @site ||= site
      end

      def raise_errors
        @raise_error = true
      end

      # How should the request body for POST and PUT requests
      # be formatted.
      #
      # Examples:
      #   class Client < Rapidash::Client
      #     encode_request_with :json
      #   end
      #
      # Arguments:
      #
      # format - Symbol. One of :url_encoded, :multipart, :json
      #
      # Returns String of set format
      def encode_request_with(format)
        format = format.to_s.to_sym

        unless [:url_encoded, :multipart, :json].include?(format)
          raise ArgumentError, 'you must pass one of :url_encoded, :multipart or :json to encode_request_with'
        end

        # Map json to multi_json to make it consistent with MutiJson parsing of responses
        format = :multi_json if format == :json

        @encoder ||= format
      end
    end

    # Instance methods

    def site
      return @site if @site
      self.class.respond_to?(:site) && self.class.site
    end

    def site=(value)
      @site = value
      @connection = nil
    end

    def normalize_url(url)
      if extension
        "#{url}.#{extension}"
      elsif self.class.respond_to?(:extension) && self.class.extension
        "#{url}.#{self.class.extension}"
      else
        url
      end
    end

    def get(url, options = {})
      request(:get, url, options)
    end

    def post(url, options = {})
      request(:post, url, options)
    end

    def put(url, options = {})
      request(:put, url, options)
    end

    def patch(url, options = {})
      request(:patch, url, options)
    end

    def delete(url, options = {})
      request(:delete, url, options)
    end

    private

    def connection_builder
      lambda do |builder|
        builder.request self.class.encoder || :url_encoded

        if self.class.respond_to?(:raise_error) && self.class.raise_error
          builder.use Faraday::Response::RaiseRapidashError
        end

        builder.use FaradayMiddleware::FollowRedirects
        builder.use FaradayMiddleware::Mashify

        builder.use FaradayMiddleware::MultiJson::ParseJson, :content_type => /\bjson$/
        builder.use FaradayMiddleware::ParseXml, :content_type => /\bxml$/

        builder.adapter :net_http
      end
    end
  end
end
