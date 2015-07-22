require 'spec_helper'

class OAuthClientTester < Rapidash::Client
  method :oauth
end

class HTTPClientTester < Rapidash::Client
  method :http
end

class HTTPClientPatchTester < HTTPClientTester
  use_patch
end

class HTTPClientExtensionTester < HTTPClientTester
  extension :js
end

class HTTPClientErrorTester < HTTPClientTester
  raise_errors
end

class TestClientTester < Rapidash::Client
  method :test
end

describe Rapidash::Client do

  let(:test_client) { TestClientTester.new({}) }

  describe "#method" do
    it "should include the HTTPClient" do
      client = HTTPClientTester.new
      expect(client.class.ancestors).to include(Rapidash::HTTPClient)
    end

    it "should include the OAuthClient" do
      client = OAuthClientTester.new({:uid => "foo", :secret => "bar", :site => "baz"})
      expect(client.class.ancestors).to include(Rapidash::OAuthClient)
    end

    it "should include the OAuthClient" do
      expect(test_client.class.ancestors).to include(Rapidash::TestClient)
    end

    it "should raise an error on anything else" do
      expect {
        class InvalidClientTester < Rapidash::Client
          method :invalid
        end
      }.to raise_error(Rapidash::ConfigurationError)
    end
  end

  describe "#use_patch" do
    it "should set the patch variable to true" do
      expect(HTTPClientPatchTester.new.class.instance_variable_get(:@patch)).to eql(true)
    end
  end

  describe "#extension" do
    it "should set the url_extension variable" do
      expect(HTTPClientExtensionTester.new.class.instance_variable_get(:@extension)).to eql(:js)
    end
  end

  describe "#raise_errors" do
    it "should set the raise_error variable" do
      expect(HTTPClientErrorTester.new.class.instance_variable_get(:@raise_error)).to eql(true)
    end
  end


  it "should raise an error when instantiated" do
    expect {
     Rapidash::Client.new
    }.to raise_error(Rapidash::ConfigurationError)
  end

  describe ".site=" do
    it "should clear the connection variable after set new site" do
      expect(test_client.instance_variable_get(:@connection)).to eql(nil)
      test_client.site = "foo"
      test_client.instance_variable_set(:@connection, "Not nil")

      test_client.site = "bar"
      expect(test_client.instance_variable_get(:@connection)).to eql(nil)
    end

    it "should set the site variable" do
      expect(test_client.instance_variable_get(:@site)).to eql(nil)
      test_client.site = "foo"
      expect(test_client.instance_variable_get(:@site)).to eql("foo")
    end
  end

  describe ".encode_request_with" do
    let(:klass) { test_client.class }

    it "should set encoder for valid argument" do
      klass.encode_request_with(:json)
      expect(klass.encoder).to eq :multi_json
    end

    it "should raise exception for invalid argument" do
      expect {
        klass.encode_request_with(:wibble)
      }.to raise_exception(ArgumentError)
    end
  end

  describe ".get" do
    it "should call request" do
      allow(test_client).to receive(:request).with(:get, "foo", {})
      test_client.get("foo")
    end
  end

  describe ".post" do
    it "should call request" do
      allow(test_client).to receive(:request).with(:post, "foo", {})
      test_client.post("foo")
    end
  end

  describe ".put" do
    it "should call request" do
      allow(test_client).to receive(:request).with(:put, "foo", {})
      test_client.put("foo")
    end
  end

  describe ".patch" do
    it "should call request" do
      allow(test_client).to receive(:request).with(:patch, "foo", {})
      test_client.patch("foo")
    end
  end

  describe ".delete" do
    it "should call request" do
      allow(test_client).to receive(:request).with(:delete, "foo", {})
      test_client.delete("foo")
    end
  end

  describe ".normalize_url" do
    it "should use the instance extension if set" do
      test_client.extension = :json
      expect(test_client.normalize_url("users")).to eql("users.json")
    end

    it "should use the class extension if set" do
      expect(HTTPClientExtensionTester.new.normalize_url("users")).to eql("users.js")
    end

    it "should return the url if no extension if set" do
      expect(test_client.normalize_url("users")).to eql("users")
    end
  end
end
