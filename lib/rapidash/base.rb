module Rapidash
  class Base
    include Urlable
    include Resourceable

    attr_accessor :url, :options, :client

    class << self
      attr_accessor :root_element

      def root(name)
        @root_element = name.to_sym
      end
    end

    def initialize(*args)
      @client, @id, options = args

      if @id.is_a?(Hash)
        options = @id
        @id = nil
      end

      @options ||= {}
      @options.merge!(options || {})
      @url = "#{base_url}#{self.class.to_s.split("::")[-1].downcase.pluralize}"
      @url += "/#{@id}" if @id
    end

    def create!(params)
      options[:method] = :post
      set_body!(params)
      call!
    end

    def update!(params)
      options[:method] = client.class.patch ? :patch : :put
      set_body!(params)
      call!
    end

    def delete!
      options[:method] = :delete
      call!
    end


    def call!
      self.options ||= {}
      options.delete(:previous_url)
      options[:header] ||= {}
      options[:header]["content-type"] = "application/json"
      method = options.delete(:method) || :get
      client.send(method, url, options)
    end

    private

    def set_body!(params)
      if self.class.root_element
        options[:body] = {self.class.root_element => params}.to_json
      else
        options[:body] = params.to_json
      end
    end

    def base_url
      old_url = self.options[:previous_url]
      old_url ? "#{old_url}/" : ""
    end
  end
end
