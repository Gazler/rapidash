require "spec_helper"

class Rapidash::Users
  def initialize(*args)
  end
end

class Users 
  def initialize(*args)
  end
end

class Rapidash::ClientTester
  include Rapidash::Clientable
  resource :users
end

class ClientTester
  include Rapidash::Clientable
  resource :users
end

class OAuthClientTester
  include Rapidash::Clientable
  method :oauth
end

class HTTPClientTester
  include Rapidash::Clientable
  method :http
end



describe Rapidash::Clientable do

  describe "#included" do
    it "should include the resource method" do
      Rapidash::ClientTester.methods.should include(:resource)
    end

    it "should include the method method" do
      Rapidash::ClientTester.methods.should include(:method)
    end
  end

  describe "#resource" do
    it "should add a method with the name of the argument" do
      Rapidash::ClientTester.new.methods.should include(:users)
    end

    it "should add a bang method with the name of the argument" do
      Rapidash::ClientTester.new.methods.should include(:users!)
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

    it "should raise an error on anything else" do
      expect {
        class InvalidClientTester
          include Rapidash::Clientable
          method :invalid
        end
      }.to raise_error(Rapidash::ConfigurationError)
    end
    
  end

  describe ".users" do
    it "should return an instance of the resource" do
      Rapidash::ClientTester.new.users.class.should eql(Rapidash::Users)
    end

    it "should not use a namespace if not in a module" do
      ClientTester.new.users.class.should eql(Users)
    end
  end

  describe ".tickets!" do
    it "should return an instance of the resource and call it" do
      users = mock
      Rapidash::Users.should_receive(:new).and_return(users)
      users.should_receive(:call!)
      Rapidash::ClientTester.new.users!
    end
  end

end
