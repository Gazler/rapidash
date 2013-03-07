module Rapidash
  module Urlable

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def url(url)
        self.class_eval do
          define_method(:initialize) do |*args|
            @client, id, options = args
            if id.is_a?(Hash)
              options = id
              id = nil
            end
            @options ||= {}
            options ||= {}
            @options.merge!(options)
            @url = url.to_s
            @url += "/#{id}" if id
          end
        end
      end
    end

  end
end
