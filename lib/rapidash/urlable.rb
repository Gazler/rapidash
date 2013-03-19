module Rapidash
  module Urlable
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def url(url)
        define_method(:initialize) do |*args|
          super(*args)
          @url = "#{base_url}#{url.to_s}"
          @url += "/#{@id}" if @id
        end
      end
    end
  end
end
