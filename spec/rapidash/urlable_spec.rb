require 'spec_helper'

class ApiTester
  attr_accessor :url, :options, :client
  include Rapidash::Urlable
  url :foo
end

class ApiTesterNoUrl
  include Rapidash::Urlable
end

describe Rapidash::Urlable do

  let!(:client) { mock }

  describe "#included" do
    it "should add the url method" do
      ApiTester.methods.should include(:url)
    end
  end

  describe "#url" do
    it "should override the initialize to set a url" do
      ApiTesterNoUrl.new.instance_variable_get(:@url).should eql(nil)
      ApiTester.new.instance_variable_get(:@url).should eql("foo")
    end

    it "should set options on the class" do
      api = ApiTester.new(client, :option1 => "foo")
      api.instance_variable_get(:@options).should eql({:option1 => "foo"})
      api.instance_variable_get(:@url).should eql("foo")
    end

    it "should let an id be set on initialization" do
      api = ApiTester.new(client, 1, :option1 => "foo")
      api.instance_variable_get(:@options).should eql({:option1 => "foo"})
      api.instance_variable_get(:@url).should eql("foo/1")
    end
  end

end
