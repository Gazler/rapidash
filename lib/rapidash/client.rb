module Rapidash
  class Client
    include Clientable
    include Resourceable

    def initialize
      raise ConfigurationError.new "Missing Method, define using `method` on your client"
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
