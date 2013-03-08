module Rapidash
  module Urlable

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def url(url)
        self.class_eval do
          define_method(:initialize) do |*args|
            super(*args)
            @url = url.to_s
            @url += "/#{@id}" if @id
          end
        end
      end
    end

  end
end
