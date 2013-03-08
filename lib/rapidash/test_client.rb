module Rapidash
  module TestClient

    attr_accessor :responses

    def initialize(options = {})
      @responses = options.delete(:responses)
    end

    def get(url, options = {})
      request(:get, url, options)
    end

    def post(url, options = {})
      request(:post, url, options)
    end

    def request(verb, url, options = {})
      Response.new(responses[verb][url])
    end
  end
end
