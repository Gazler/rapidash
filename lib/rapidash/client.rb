module Rapidash
  class Client
    include Resourceable

    attr_accessor :extension

    def initialize
      raise ConfigurationError.new "Missing Method, define using `method` on your client"
    end

    class << self
      attr_accessor :patch, :raise_error

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
        @extension = extension
      end

      def site(site = nil)
        @site ||= site
      end

      def raise_errors
        @raise_error = true
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
  end
end
