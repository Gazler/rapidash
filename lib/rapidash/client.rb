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
  end
end
