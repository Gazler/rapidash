module Rapidash
  module Resourceable
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def resource(*names)
        options = names.extract_options!

        mod = self.to_s.split("::")[0...-1]
        if mod.empty?
          mod = Object
        else
          mod = Object.const_get(mod.join("::"))
        end

        names.each do |name|
          if options[:class_name]
            class_name = options[:class_name]
          else
            class_name = name.to_s.camelcase.singularize
          end

          begin
            klass = "#{mod}::#{class_name}".constantize
          rescue NameError
            klass = class_name.pluralize.constantize
            Kernel.warn "Using #{class_name.pluralize} instead of #{class_name.singularize}"
          end

          define_method(name) do |*args|
            if self.respond_to?(:url)
              options = {:previous_url => self.url}
              if args[args.length - 1].is_a?(Hash)
                args[args.length - 1].merge!(options)
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
