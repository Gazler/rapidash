#Required for pluralization and camelcasing
require "active_support/core_ext/string"

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
  mattr_accessor :error_class

  class ParseError < StandardError; end
  class ConfigurationError < StandardError; end
end
