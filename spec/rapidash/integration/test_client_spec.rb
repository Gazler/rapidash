require 'spec_helper'

module Integration

  class Repo < Rapidash::Base
  end

  class User < Rapidash::Base
    url "members"
    resource :repos
  end

  class Project < Rapidash::Base
    root :project
    resource :users
  end

  class Client < Rapidash::Client
    method :test
    resource :users, :projects
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

project_with_root = OpenStruct.new({
  :headers => { "content-type" => "application/json" },
  :body    => { :project => { :name => 'rapidash' } }.to_json
})

responses = {
  :get => {
    "members/Gazler" => gazler,
    "members/Gazler/repos" => repos
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

describe "with root" do
  let(:response){{:get => {"projects/rapidash" => project_with_root}}}
  let!(:client){ Integration::Client.new(:responses => response)}

  it "should get project name" do
    client.projects!("rapidash").name.should eql "rapidash"
  end
end
