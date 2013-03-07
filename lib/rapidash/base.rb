module Rapidash
  class Base

    include Urlable
    attr_accessor :url, :options, :client

    def initialize
      raise ConfigurationError.new "Missing URL attribute on the resource, set it by calling `url` in your resource class"
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
