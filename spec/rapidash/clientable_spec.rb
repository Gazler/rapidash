require "spec_helper"

class OAuthClientTester
  include Rapidash::Clientable
  method :oauth
end

class HTTPClientTester
  include Rapidash::Clientable
  method :http
end

class HTTPClientPatchTester < HTTPClientTester
  use_patch
end

class HTTPClientExtensionTester < HTTPClientTester
  extension :json
end

class HTTPClientErrorTester < HTTPClientTester
  raise_errors
end


class TestClientTester
  include Rapidash::Clientable
  method :test
end




describe Rapidash::Clientable do

  describe "#included" do
    it "should include the method method" do
      HTTPClientTester.methods.map { |m| m.to_sym }.should include(:method)
    end
  end

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
        class InvalidClientTester
          include Rapidash::Clientable
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
      HTTPClientExtensionTester.new.class.instance_variable_get(:@url_extension).should eql(:json)
    end
  end

  describe "#raise_errors" do
    it "should set the raise_error variable" do
      HTTPClientErrorTester.new.class.instance_variable_get(:@raise_error).should eql(true)
    end
  end

end
