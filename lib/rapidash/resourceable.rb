module Rapidash
  module Resourceable
    def self.included(base)
      base.extend ClassMethods
    end

    def resource(name, id = nil, options = {})
      options[:url] ||= name
      if self.respond_to?(:url)
        options = {:previous_url => self.url}.merge!(options)
      end
      client = self
      client = self.client if self.respond_to?(:client)
      Rapidash::Base.new(client, id, options)
    end

    def resource!(*args)
      self.resource(*args).call!
    end


    module ClassMethods
      def resource(*names)
        options = names.extract_options!

        mod = self.to_s.split("::")[0...-1]
        mod = mod.empty? ? Object : Object.const_get(mod.join("::"))

        names.each do |name|
          if options[:class_name]
            class_name = options[:class_name]
          else
            class_name = name.to_s.camelcase.singularize
          end

          begin
            klass = "#{mod}::#{class_name}".constantize
          rescue NameError
            Kernel.warn "[DEPRECATED] - RAPIDASH WARNING using #{class_name.pluralize} instead of #{class_name.singularize} - please either use `#{class_name.singularize}` or set the class name with `resource #{name}, :class_name => #{class_name.pluralize}` implicit plural naming will be deprecated in Rapidash 1.0"
            klass = "#{mod}::#{class_name}".pluralize.constantize
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
