module Rapidash
  module Clientable

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def method(method)
        case method
        when :http then include HTTPClient
        when :oauth then include OAuthClient
        when :test then include TestClient
        else
          raise ConfigurationError.new "Invalid API Authentication Method"
        end
      end
    end
  end
end
