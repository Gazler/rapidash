require 'rubygems'
require 'json'
require 'hashie'

module Rapidash
  class Response

    class << self
      def new(response)
        return nil unless response.body
        type = response.headers["content-type"]
        if type.include?("application/json")
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
        else
          raise ParseError.new("Cannot parse content type: #{response.headers["content-type"]}")
        end
      end
    end

  end
end

