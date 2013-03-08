require 'spec_helper'

module Integration

  class Repos < Rapidash::Base
  end

  class Users < Rapidash::Base
    url "members"
    resource :repos
  end

  class Client < Rapidash::Client
    method :test
    resource :users
  end

end

gazler = OpenStruct.new({
  :headers => { "content-type" => "application/json" },
  :body => { :name => "Gary Rennie" }.to_json
})

repos = OpenStruct.new({
  :headers => { "content-type" => "application/json" },
  :body => [ { :name => "Githug" } ].to_json
})

responses = {
  :get => {
    "members/Gazler" => gazler,
    "members/Gazler/repos" => repos,
  }
}

describe "An actual Rapidash Client" do

  let!(:client) { Integration::Client.new(:responses => responses) }

  it "should get the user from the API" do
    client.users!("Gazler").name.should eql("Gary Rennie")
  end

  it "should get the repos from A user" do
    client.users("Gazler").repos![0].name.should eql("Githug")
  end
end
