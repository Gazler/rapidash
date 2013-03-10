module Rapidash
  module Clientable

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      attr_accessor :patch, :url_extension

      def method(method)
        case method
        when :http then include HTTPClient
        when :oauth then include OAuthClient
        when :test then include TestClient
        else
          raise ConfigurationError.new "Invalid API Authentication Method"
        end
      end

      def use_patch
        @patch = true
      end

      def extension(extension)
        @url_extension = extension
      end
    end
  end
end
