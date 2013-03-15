require 'json'
require 'hashie'

module Rapidash
  class Response

    class << self
      def new(response)
        return nil unless response.body
        type = response.headers["content-type"]
          body = JSON.parse(response.body)
          if body.kind_of?(Hash)
            return Hashie::Mash.new(body)
          elsif body.kind_of?(Array)
            output = []
            body.each do |el|
              output << Hashie::Mash.new(el)
            end
            return output
          end
      rescue JSON::ParserError => e
        raise ParseError.new("Failed to parse content for type: #{response.headers["content-type"]}")
      end
    end

  end
end

