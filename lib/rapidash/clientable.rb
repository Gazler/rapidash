module Rapidash
  module Clientable

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def method(method)
        if method == :http
          include HTTPClient
        elsif method == :oauth
          include OAuthClient
        else
          raise ConfigurationError.new "Invalid API Authentication Method"
        end
      end

      def resource(name)
        mod = self.to_s.split("::")[0...-1]
        if mod.empty?
          mod = Kernel
        else
          mod = Kernel.const_get(mod.join("::"))
        end
        klass = mod.const_get(name.capitalize)
        define_method(name) do |*args|
          klass.new(self, *args)
        end
        define_method("#{name}!".to_sym) do |*args|
          klass.new(self, *args).call!
        end
      end
    end
  end
end
