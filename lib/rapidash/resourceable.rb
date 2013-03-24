module Rapidash
  module Resourceable
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def resource(*names)
        mod = self.to_s.split("::")[0...-1]
        if mod.empty?
          mod = Object
        else
          mod = Object.const_get(mod.join("::"))
        end

        names.each do |name|
          class_name = name.to_s.camelcase.singularize
          unless mod.const_defined?(class_name)
            class_name = class_name.pluralize 
            Kernel.warn "Using #{class_name} instead of #{class_name.singularize}"
          end
          klass = mod.const_get(class_name)

          define_method(name) do |*args|
            if self.respond_to?(:url)
              options = {:previous_url => self.url}
              if args.last.is_a?(Hash)
                args.last.merge!(options)
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
