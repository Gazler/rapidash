require 'spec_helper'

module Integration
  class Repo < Rapidash::Base
  end

  class User < Rapidash::Base
    url "members"
    resource :repos
  end

  class Client < Rapidash::Client
    method :test
    resource :users
  end
end

responses = {
  :get => {
    "members/Gazler" => { :name => "Gary Rennie" }.to_json,
    "members/Gazler/repos" => [{ :name => "Githug" }].to_json,
  }
}

describe "An actual Rapidash Client" do
  let(:client) { Integration::Client.new(responses, :json => true) }

  it "should get the user from the API" do
    client.users!("Gazler").name.should eql("Gary Rennie")
  end

  it "should get the repos from A user" do
    client.users("Gazler").repos![0].name.should eql("Githug")
  end
end
