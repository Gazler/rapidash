module Rapidash
  class Base

    include Urlable
    attr_accessor :url, :options, :client

    def initialize(*args)
      @client, @id, options = args
      if @id.is_a?(Hash)
        options = @id
        @id = nil
      end
      @options ||= {}
      options ||= {}
      @options.merge!(options)
      @url = self.class.to_s.split("::")[-1].downcase
      @url += "/#{@id}" if @id
    end


    def call!
      self.options ||= {}
      self.options[:header] ||= {}
      self.options[:header]["content-type"] = "application/json"
      method = self.options.delete(:method) || :get
      client.send(method, url, self.options)
    end
  end
end
