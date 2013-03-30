require "spec_helper"

class Rapidash::Repo
  attr_accessor :client, :args
  def initialize(client, *args)
    @client = client
    @args = args
  end
end

class Rapidash::User
  include Rapidash::Resourceable
  attr_accessor :client, :url
  resource :repos
  def initialize(client, *args)
    @client = client
    self
  end
end

class User
  def initialize(*args)
  end
end

class AdminUser
  def initialize(*args)
  end
end

class CoreMembers
  def initialize(*args)
  end
end


class Rapidash::ClientTester
  include Rapidash::Resourceable
  resource :users
end

class Rapidash::MultiResourceTester
  include Rapidash::Resourceable
  resource :users, :repos
end

class ClientTester
  include Rapidash::Resourceable
  resource :users
end

describe Rapidash::Resourceable do

  describe "#included" do
    it "should include the resource method" do
      Rapidash::ClientTester.methods.map { |m| m.to_sym }.should include(:resource)
    end

  end

  describe "#resource" do
    it "should add a method with the name of the argument" do
      Rapidash::ClientTester.new.methods.map { |m| m.to_sym }.should include(:users)
    end

    it "should not fail when presented with a multi-word resource" do
      expect { 
        class ClientTester
          resource :admin_users
        end
      }.to_not raise_error(NameError)
    end

    it "should load the plural class with a warning if the singular is not defined" do
      Kernel.should_receive(:warn).with("Using CoreMembers instead of CoreMember")
      class ClientTester
        resource :core_members
      end
    end

    it "should add a bang method with the name of the argument" do
      Rapidash::ClientTester.new.methods.map { |m| m.to_sym }.should include(:users!)
    end

    it "should add a method for each resource is an array is passed" do
      methods = Rapidash::MultiResourceTester.new.methods.map { |m| m.to_sym }
      (methods & [:users, :users!, :repos, :repos!]).length.should eql(4)
    end
  end

  describe ".users" do
    it "should return an instance of the resource" do
      Rapidash::ClientTester.new.users.class.should eql(Rapidash::User)
    end

    it "should not use a namespace if not in a module" do
      ClientTester.new.users.class.should eql(User)
    end
  end

  describe ".tickets!" do
    it "should return an instance of the resource and call it" do
      users = mock
      Rapidash::User.should_receive(:new).and_return(users)
      users.should_receive(:call!)
      Rapidash::ClientTester.new.users!
    end
  end

  describe "chaining resources" do
    it "should allow resources to be nested" do
      client = mock
      users = Rapidash::User.new(client)
      users.methods.map { |m| m.to_sym }.should include(:repos)
      users.methods.map { |m| m.to_sym }.should include(:repos!)
    end

    it "should maintain the client across resources " do
      client = mock
      users = Rapidash::User.new(client)
      users.repos.instance_variable_get(:@client).should eql(client)
    end

    it "should maintain the URL when chaining" do
      client = mock
      users = Rapidash::User.new(client)
      users.repos.instance_variable_get(:@args)[0].keys.should include(:previous_url)
    end

    it "should maintain the URL as well as the options when chaining" do
      client = mock
      users = Rapidash::User.new(client)
      repos = users.repos(:params => {:foo => :bar})
      repos.instance_variable_get(:@args)[0].should include(:params)
      repos.instance_variable_get(:@args)[0].should include(:previous_url)
    end
  end

  describe "resource with module" do
    module Facebook
      class User
        def initialize(*args)
        end
      end

      module Its
        module A
          class DeepResource
          end
        end
      end
    end

    class ModuleTester
      include Rapidash::Resourceable
      resource :users, :class_name => "Facebook::User"
      resource :deep_resources, :class_name => "Facebook::Its::A::DeepResource"
    end

    it "should find user in another module" do
      ModuleTester.new.users.class.should eql(Facebook::User)
    end
  end
end
