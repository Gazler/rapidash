module Rapidash
  module Resourceable

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def resource(name)
        mod = self.to_s.split("::")[0...-1]
        if mod.empty?
          mod = Kernel
        else
          mod = Kernel.const_get(mod.join("::"))
        end
        klass = mod.const_get(name.to_s.capitalize)

        def get_client(me)
          client = me
          if me.respond_to?(:client)
            client = me.client
          end
          client
        end

        mod = self

        define_method(name) do |*args|
          if self.respond_to?(:url)
            options = {:previous_url => self.url}
            if args[args.length].is_a?(Hash)
              args[args.length].merge!(options)
            else
              args << options
            end
          end
          klass.new(mod.get_client(self), *args)
        end
        define_method("#{name}!".to_sym) do |*args|
          self.send(name, *args).call!
        end
      end
    end
  end
end
