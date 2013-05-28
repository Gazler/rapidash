module Rapidash
  # Custom error class for rescuing from all Basecamp errors
  class ResponseError < StandardError
    attr_reader :response, :body, :status, :method, :url

    def initialize(response = nil)
      @response = response

      @body = response[:body]
      @status = response[:status].to_i
      @method = response[:method].to_s.upcase
      @url = response[:url]

      super(build_message)
    end

    private

    def build_message
      return nil if response.blank?

      if body.kind_of?(String)
        message = body
      else
        errors = []

        body.each_pair do |attribute, messages|
          messages.each { |msg| errors.push "#{attribute} #{msg}" }
        end

        message = errors.join(', ')
      end

      "#{status} #{method} #{url} | Errors: #{message}"
    end
  end
end
