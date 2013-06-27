require 'spec_helper'

class User < Rapidash::Base
  collection :active
end

class People < Rapidash::Base
  collection :suspend_all, :path => 'deactivate', :method => :post
end

class Client < Rapidash::Client
  method :http
  site 'http://acme.com'

  resource :users
  resource :people
end

describe Rapidash::Client do
  let(:client) { Client.new }

  context "standand collection" do
    let(:resource) { client.users }

    it "should define a new method" do
      expect(resource).to respond_to(:active!)
    end

    it "should call with the updated URL" do
      client.should_receive(:get).with('users/active', { :headers => { "content-type" => "application/json" }})
      resource.active!
    end

    it "should not update the URL on the resource" do
      resource.active!
      expect(resource.url).to eq 'users'
    end
  end

  context "additional options" do
    let(:resource) { client.people }

    it "should define a new method" do
      expect(resource).to respond_to(:suspend_all!)
    end

    it "should call with the updated URL" do
      client.should_receive(:post).with('people/deactivate', { :headers => { "content-type" => "application/json" }})
      resource.suspend_all!
    end

    it "should not update the URL on the resource" do
      resource.suspend_all!
      expect(resource.url).to eq 'people'
    end
  end
end
