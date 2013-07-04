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
  #     response.body # => "{"errors":["title can't be blank", "body can't be blank"]}"
  #   end
  #
  # Hint: Can be easily sub-classed to provide a custom exception handler class
  # with specific error formatting. Defining an `errors` method that returns a String or Array
  # will include the errors in the exception message:
  #
  #   class MyCustomResponseError < Rapidash::ResponseError
  #     def errors
  #       data = JSON.parse(body)
  #       data['errors']
  #     end
  #   end
  #
  #   Rapidash.response_exception_class = MyCustomResponseError
  #
  #   client.posts.create!(title: '')
  #   MyCustomResponseError: 422 POST http://acme.com/api/v1/posts.json | Errors: title can't be blank, body can't be blank
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

      super
    end

    def to_s
      msg = "#{status} #{method} #{url}"

      if respond_to?(:errors) && !(errors.blank?)
        errors.map(&:to_s).join(', ') if errors.kind_of?(Array)
        msg = "#{msg} | Errors: #{errors.to_s}"
      end

      msg
    end
  end
end
