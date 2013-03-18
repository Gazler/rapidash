module Rapidash
  module TestClient
    attr_accessor :responses

    def initialize(options = {})
      @responses = options.delete(:responses)
    end

    def request(verb, url, options = {})
      Response.new(responses[verb][url])
    end
  end
end
