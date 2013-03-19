require 'spec_helper'

class Client < Rapidash::Client
  method :test
end


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

class TestClientTester
  method :test
end

describe Rapidash::Client do

  let!(:subject) { Client.new }

  describe "#method" do
    it "should include the HTTPClient" do
      client = HTTPClientTester.new
      client.class.ancestors.should include(Rapidash::HTTPClient)
    end

    it "should include the OAuthClient" do
      client = OAuthClientTester.new({:uid => "foo", :secret => "bar", :site => "baz"})
      client.class.ancestors.should include(Rapidash::OAuthClient)
    end

    it "should include the OAuthClient" do
      client = TestClientTester.new
      client.class.ancestors.should include(Rapidash::TestClient)
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
      HTTPClientPatchTester.new.class.instance_variable_get(:@patch).should eql(true)
    end
  end

  describe "#extension" do
    it "should set the url_extension variable" do
      HTTPClientExtensionTester.new.class.instance_variable_get(:@extension).should eql(:js)
    end
  end

  describe "#raise_errors" do
    it "should set the raise_error variable" do
      HTTPClientErrorTester.new.class.instance_variable_get(:@raise_error).should eql(true)
    end
  end


  it "should raise an error when instantiated" do
    expect {
     Rapidash::Client.new
    }.to raise_error(Rapidash::ConfigurationError)
  end

  describe ".site=" do
    it "should clear the connection variable after set new site" do
      subject.instance_variable_get(:@connection).should eql(nil)
      subject.site = "foo"
      subject.instance_variable_set(:@connection, "Not nil")

      subject.site = "bar"
      subject.instance_variable_get(:@connection).should eql(nil)
    end

    it "should set the site variable" do
      subject.instance_variable_get(:@site).should eql(nil)
      subject.site = "foo"
      subject.instance_variable_get(:@site).should eql("foo")
    end
  end


  describe ".get" do
    it "should call request" do
      subject.should_receive(:request).with(:get, "foo", {})
      subject.get("foo")
    end
  end

  describe ".post" do
    it "should call request" do
      subject.should_receive(:request).with(:post, "foo", {})
      subject.post("foo")
    end
  end

  describe ".put" do
    it "should call request" do
      subject.should_receive(:request).with(:put, "foo", {})
      subject.put("foo")
    end
  end

  describe ".patch" do
    it "should call request" do
      subject.should_receive(:request).with(:patch, "foo", {})
      subject.patch("foo")
    end
  end

  describe ".delete" do
    it "should call request" do
      subject.should_receive(:request).with(:delete, "foo", {})
      subject.delete("foo")
    end
  end

  describe ".normalize_url" do
    it "should use the instance extension if set" do
      subject.extension = :json
      subject.normalize_url("users").should eql("users.json")
    end

    it "should use the class extension if set" do
      HTTPClientExtensionTester.new.normalize_url("users").should eql("users.js")
    end

    it "should return the url if no extension if set" do
      subject.normalize_url("users").should eql("users")
    end
  end
end
