# Rapidash::TestClient
# A dummy client for testing with. Create a new test
# client by including this module and initializing
# with a set of responses.
# Example:
#
#   class TesterClient
#    include Rapidash::TestClient
#   end
#
#   responses = {
#     get: { "foo" => "bar" },
#     post: { "baz" => "data" }
#   }
#
#   client = TesterClient.new(responses)
#
# Example with JSON support:
#
#   responses = {
#     get: { "foo" => '{"some": 123, "json": 456}' }
#   }
#
#   client = TesterClient.new(responses, json: true)
module Rapidash
  module TestClient
    attr_reader :responses, :stubs, :json

    def initialize(responses, options = {})
      @json = options[:json] || false
      @responses = responses
      build_stubs
    end

    def request(verb, url, options = {})
      connection.send(verb, url, options).body
    end

    private

    def build_stubs
      @stubs = Faraday::Adapter::Test::Stubs.new do |stub|
        responses.each_pair do |verb, req|
          req.each_pair do |url, body|
            stub.send(verb, url) { [200, {}, body] }
          end
        end
      end
    end

    def connection
      @connection ||= Faraday.new do |builder|
        builder.adapter :test, stubs
        builder.use FaradayMiddleware::Mashify

        if json
          builder.use FaradayMiddleware::ParseJson
        end
      end
    end
  end
end
