require "spec_helper"

class HTTPTester
  include Rapidash::HTTPClient
end

describe Rapidash::HTTPClient do

  let!(:subject) { HTTPTester.new }

  describe ".site=" do
    it "should clear the connection variable" do
      subject.instance_variable_get(:@connection).should eql(nil)
      subject.connection
      subject.instance_variable_get(:@connection).class.should eql(Faraday::Connection)
      subject.site = "foo"
      subject.instance_variable_get(:@connection).should eql(nil)
    end

    it "should set the site variable" do
      subject.instance_variable_get(:@site).should eql(nil)
      subject.site = "foo"
      subject.instance_variable_get(:@site).should eql("foo")
    end
  end

  describe ".connection" do
    it "should create a Faraday object" do
      subject.connection.class.should eql(Faraday::Connection)
    end
  end

  describe ".request" do

    let!(:valid_response) { OpenStruct.new(:status => "200")}
    let!(:redirect_response) { OpenStruct.new(:status => "301", :headers => {"location" => "http://example.com/redirect"})}

    before(:each) do
      subject.site = "http://example.com"
      Rapidash::Response.should_receive(:new).and_return("response")
    end

    it "should add an extension if one is set" do
      subject.extension = :json
      subject.connection.should_receive(:run_request).with(:get, "http://example.com/foo.json", nil, nil).and_return(valid_response)
      subject.request(:get, "foo")
    end

    it "should return a response object" do
      subject.connection.should_receive(:run_request).with(:get, "http://example.com/foo", nil, nil).and_return(valid_response)
      response = subject.request(:get, "foo")
      response.should eql("response")
    end

    it "should perform a redirect" do
      subject.connection.should_receive(:run_request).with(:get, "http://example.com/foo", nil, nil).and_return(redirect_response)
      subject.connection.should_receive(:run_request).with(:get, "http://example.com/redirect", nil, nil).and_return(valid_response)
      response = subject.request(:get, "foo")
      response.should eql("response")
    end
  end

end
