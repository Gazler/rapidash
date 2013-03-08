require "spec_helper"

class OAuthClientTester
  include Rapidash::Clientable
  method :oauth
end

class HTTPClientTester
  include Rapidash::Clientable
  method :http
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

end
