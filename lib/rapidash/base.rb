module Rapidash
  class Base

    include Urlable
    include Resourceable
    attr_accessor :url, :options, :client

    def initialize(*args)
      @client, @id, options = args

      if @id.is_a?(Hash)
        options = @id
        @id = nil
      end

      @options ||= {}
      @options.merge!(options || {})
      @url = "#{base_url}#{self.class.to_s.split("::")[-1].downcase}"
      @url += "/#{@id}" if @id
    end

    def create!(params)
      self.options[:method] = :post
      self.options[:body] = params.to_json
      call!
    end

    def update!(params)
      self.options[:method] = client.class.patch ? :patch : :put
      self.options[:body] = params.to_json
      call!
    end

    def delete!
      self.options[:method] = :delete
      call!
    end


    def call!
      self.options ||= {}
      self.options.delete(:previous_url)
      self.options[:header] ||= {}
      self.options[:header]["content-type"] = "application/json"
      method = self.options.delete(:method) || :get
      client.send(method, url, self.options)
    end

    private

    def base_url
      if old_url = self.options[:previous_url]
        return "#{old_url}/"
      end
      ""
    end
  end
end
