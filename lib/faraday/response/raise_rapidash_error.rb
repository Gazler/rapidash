require 'faraday'

module Faraday
  class Response::RaiseRapidashError < Response::Middleware

    def on_complete(env)
      status = env[:status].to_i
      klass = Rapidash.response_exception_class || Rapidash::ResponseError
      raise klass.new(env) if (400..599).include?(status)
    end

  end
end
