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

  let!(:client) { double }
  let(:custom_header) { { :header => { user_agent: 'Experimentation v3.14'} } }

  describe "#included" do
    it "should add the url method" do
      expect(ApiTester.methods.map { |m| m.to_sym}).to include(:url)
    end
  end

  describe "#url" do
    it "should override the initialize to set a url" do
      expect(ApiTesterNoUrl.new.instance_variable_get(:@url)).to eql("apitesternourls")
      expect(ApiTester.new.instance_variable_get(:@url)).to eql("foo")
    end

    it "should set options on the class" do
      api = ApiTester.new(client, :option1 => "foo")
      expect(api.instance_variable_get(:@options)).to eql({:option1 => "foo"})
      expect(api.instance_variable_get(:@url)).to eql("foo")
    end

    it "should allow custom headers" do
      api = ApiTester.new(client,custom_header)
      expect(api.instance_variable_get(:@options)).to eql(custom_header)
      expect(api.instance_variable_get(:@url)).to eql("foo")
    end

    it "should let an id be set on initialization" do
      api = ApiTester.new(client, 1, :option1 => "foo")
      expect(api.instance_variable_get(:@options)).to eql({:option1 => "foo"})
      expect(api.instance_variable_get(:@url)).to eql("foo/1")
    end

    it "should call base_url on when constructing the url" do
      api = BaseUrlTester.new(client, 1)
      expect(api.instance_variable_get(:@url)).to eql("BASE_URL/foo/1")
    end
  end

end
