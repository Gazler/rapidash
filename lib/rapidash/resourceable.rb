module Rapidash
  module Resourceable

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def resource(*names)
        mod = self.to_s.split("::")[0...-1]
        if mod.empty?
          mod = Kernel
        else
          mod = Kernel.const_get(mod.join("::"))
        end



        names.each do |name|
          klass = mod.const_get(name.to_s.capitalize)

          define_method(name) do |*args|
            if self.respond_to?(:url)
              options = {:previous_url => self.url}
              if args[args.length].is_a?(Hash)
                args[args.length].merge!(options)
              else
                args << options
              end
            end
            client = self
            client = self.client if self.respond_to?(:client)
            klass.new(client, *args)
          end

          define_method("#{name}!".to_sym) do |*args|
            self.send(name, *args).call!
          end
        end
      end

    end

  end
end
