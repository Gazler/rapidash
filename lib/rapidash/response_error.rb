module Rapidash

  # Rapidash::ResponseError
  # Exception that gets raised if the response is an error (4xx or 5xx)
  # Raised by Faraday::Response::RaiseRapidashError
  # see lib/faraday/response/raise_rapidash_error.rb
  #
  # Formats a readable error message including HTTP status, method and requested URL
  #
  # Examples:
  #
  #   client.posts.create!(title: '')
  #   Rapidash::ResponseError: 422 POST http://acme.com/api/v1/posts.json
  #
  #   begin
  #     client.posts.create!(title: '')
  #   rescue Rapidash::ResponseError => response
  #     response.status # => 422
  #     response.method # => "POST"
  #     response.url # => "http://acme.com/api/v1/posts.json"
  #     response.body # => "{"errors":[{"title":["can't be blank"]},{"body":["can't be blank"]}]}"
  #   end
  #
  # Hint: Can be easily sub-classed to provide a custom exception handler class
  # with specific error formatting:
  #
  #   class MyCustomResponseError < Rapidash::ResponseError
  #     def errors
  #       data = JSON.parse(body)
  #       data[:errors]
  #     end
  #   end
  #
  #   Rapidash.response_exception_class = MyCustomResponseError
  #
  #   client.posts.create!(title: '')
  #   MyCustomResponseError: 422 POST http://acme.com/api/v1/posts.json
  #
  #   begin
  #     client.posts.create!(title: '')
  #   rescue Rapidash::ResponseError => response
  #     response.status # => 422
  #     response.errors # => ["title can't be blank", "body can't be blank"]
  #   end
  #
  class ResponseError < StandardError
    attr_reader :response, :body, :status, :method, :url

    def initialize(response = nil)
      @response = response

      @body = response[:body]
      @status = response[:status].to_i
      @method = response[:method].to_s.upcase
      @url = response[:url]

      super(message)
    end

    private

    def message
      "#{status} #{method} #{url}"
    end
  end
end
