module Rapidash
  class Client
    include Clientable
    include Resourceable

      def initialize
        raise ConfigurationError.new "Missing Method, define using `method` on your client"
      end
  end
end
