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
      expect(Rapidash::ClientTester.methods.map { |m| m.to_sym }).to include(:resource)
    end
  end

  describe "instance methods" do
    let(:client) { ClientTester.new }

    describe ".resource" do
      it "should create a Rapidash::Base" do
        expect(client.resource(:users, 1).class).to eql(Rapidash::Base)
      end

      it "should set the url to the resource name" do
        resource = client.resource(:users)
        expect(resource.url).to eql("users")
      end

      it "should pass the id through if specified" do
        resource = client.resource(:users, 1)
        expect(resource.url).to eql("users/1")
      end

      it "should pass the previous url through" do
        def client.url
          "base"
        end
        resource = client.resource(:users, 1)
        expect(resource.url).to eql("base/users/1")
      end

      it "should pass the client through" do
        resource = client.resource(:users, 1)
        expect(resource.client).to eql(client)
      end

      it "should allow an explicit url to be sent" do
        resource = client.resource(:users, 1, :url => "people")
        expect(resource.url).to eql("people/1")
      end

      it "should be chainable" do
        resource = client.resource(:users, 1).resource(:comments, 2)
        expect(resource.url).to eql("users/1/comments/2")
        expect(resource.client).to eql(client)
      end
    end

    describe ".resource!" do
      it "should call the call! method on a resource" do
        resource = double
        allow(Rapidash::Base).to receive(:new).and_return(resource)
        expect(resource).to receive(:call!)
        client.resource!(:users, 1)
      end
    end
  end

  describe "#resource" do
    it "should add a method with the name of the argument" do
      expect(Rapidash::ClientTester.new.methods.map { |m| m.to_sym }).to include(:users)
    end

    it "should not fail when presented with a multi-word resource" do
      expect {
        class ClientTester
          resource :admin_users
        end
      }.to_not raise_error
    end

    it "should load the plural class with a warning if the singular is not defined" do
      expect(Kernel).to receive(:warn).with("[DEPRECATED] - RAPIDASH WARNING using CoreMembers instead of CoreMember - please either use `CoreMember` or set the class name with `resource core_members, :class_name => CoreMembers` implicit plural naming will be deprecated in Rapidash 1.0")
      class ClientTester
        resource :core_members
      end
    end

    it "should add a bang method with the name of the argument" do
      expect(Rapidash::ClientTester.new.methods.map { |m| m.to_sym }).to include(:users!)
    end

    it "should add a method for each resource is an array is passed" do
      methods = Rapidash::MultiResourceTester.new.methods.map { |m| m.to_sym }
      expect((methods & [:users, :users!, :repos, :repos!]).length).to eql(4)
    end
  end

  describe ".users" do
    it "should return an instance of the resource" do
      expect(Rapidash::ClientTester.new.users.class).to eql(Rapidash::User)
    end

    it "should not use a namespace if not in a module" do
      expect(ClientTester.new.users.class).to eql(User)
    end
  end

  describe ".tickets!" do
    it "should return an instance of the resource and call it" do
      users = double
      expect(Rapidash::User).to receive(:new).and_return(users)
      expect(users).to receive(:call!)
      Rapidash::ClientTester.new.users!
    end
  end

  describe "chaining resources" do
    it "should allow resources to be nested" do
      client = double
      users = Rapidash::User.new(client)
      expect(users.methods.map { |m| m.to_sym }).to include(:repos)
      expect(users.methods.map { |m| m.to_sym }).to include(:repos!)
    end

    it "should maintain the client across resources " do
      client = double
      users = Rapidash::User.new(client)
      expect(users.repos.instance_variable_get(:@client)).to eql(client)
    end

    it "should maintain the URL when chaining" do
      client = double
      users = Rapidash::User.new(client)
      expect(users.repos.instance_variable_get(:@args)[0].keys).to include(:previous_url)
    end

    it "should maintain the URL as well as the options when chaining" do
      client = double
      users = Rapidash::User.new(client)
      repos = users.repos(:params => {:foo => :bar})
      expect(repos.instance_variable_get(:@args)[0]).to include(:params)
      expect(repos.instance_variable_get(:@args)[0]).to include(:previous_url)
    end
  end

  describe "resource with module" do
    module Facebook
      class User
        def initialize(*args)
        end
      end

      class Posts
        def initialize(*args)
        end
      end
    end

    module SomeModule
      module SomeSubModule
        class User
          def initialize(*args)
          end
        end

        class Post
          def initialize(*args)
          end
        end
      end
    end

    class ModuleTester
      include Rapidash::Resourceable
      resource :users, :class_name => "Facebook::User"
      resource :posts, :class_name => Facebook::Posts
      resource :deep_users, :class_name => "SomeModule::SomeSubModule::User"
      resource :deep_posts, :class_name => SomeModule::SomeSubModule::Post
    end

    it "should find user in another module" do
      expect(ModuleTester.new.users.class).to eql(Facebook::User)
    end

    it "should allow a plural class name" do
      expect(ModuleTester.new.posts.class).to eql(Facebook::Posts)
    end

    it "should find deep_users in a nested module" do
      expect(ModuleTester.new.deep_users.class).to eql(SomeModule::SomeSubModule::User)
    end

    it "should find deep_posts in a nested class name" do
      expect(ModuleTester.new.deep_posts.class).to eql(SomeModule::SomeSubModule::Post)
    end

    it "should not raise a wrong constant NameError" do
      expect {
        module Deep
          module ModuleTester
            class MyResource < Rapidash::Base
              resource :users, :class_name => "Facebook::User"
            end
          end
        end
      }.to_not raise_error
    end

  end
end
