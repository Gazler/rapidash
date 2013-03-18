require 'spec_helper'

class ApiTester < Rapidash::Base
  url :foo
end

class BaseUrlTester < Rapidash::Base
  url :foo
  
  private
  def base_url
    "BASE_URL/"
  end
end

class ApiTesterNoUrl < Rapidash::Base
end

describe Rapidash::Urlable do

  let!(:client) { mock }

  describe "#included" do
    it "should add the url method" do
      ApiTester.methods.map { |m| m.to_sym}.should include(:url)
    end
  end

  describe "#url" do
    it "should override the initialize to set a url" do
      ApiTesterNoUrl.new.instance_variable_get(:@url).should eql("apitesternourls")
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

    it "should call base_url on when constructing the url" do
      api = BaseUrlTester.new(client, 1)
      api.instance_variable_get(:@url).should eql("BASE_URL/foo/1")
    end
  end

end
