#Required for pluralization and camelcasing
require "active_support/core_ext/string"
require "json"

require "rapidash/version"

require "faraday/response/raise_rapidash_error"
require "rapidash/response_error"

require "rapidash/resourceable"
require "rapidash/client"

require "rapidash/urlable"
require "rapidash/base"

require "rapidash/http_client"
require "rapidash/oauth_client"
require "rapidash/test_client"

module Rapidash
  def self.response_exception_class=(obj)
    @@response_exception_class = obj
  end

  def self.response_exception_class
    @@response_exception_class = nil unless defined? @@response_exception_class

    @@response_exception_class
  end

  class ParseError < StandardError; end
  class ConfigurationError < StandardError; end
end
