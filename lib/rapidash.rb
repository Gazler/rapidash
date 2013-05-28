#Required for pluralization and camelcasing
require "active_support/core_ext/string"

require "rapidash/version"

require "rapidash/response"

require "rapidash/resourceable"
require "rapidash/client"

require "rapidash/urlable"
require "rapidash/base"

require "rapidash/http_client"
require "rapidash/oauth_client"
require "rapidash/test_client"

module Rapidash
  class ParseError < StandardError; end
  class ConfigurationError < StandardError; end
end
