require "spec_helper"

class HTTPTester < Rapidash::Client
  include Rapidash::HTTPClient
end

class HTTPSiteTester < HTTPTester
  class << self
    attr_accessor :site
  end
end

class HTTPErrorTester < HTTPSiteTester
  def self.raise_error
    true
  end
end

describe Rapidash::HTTPClient do

  let!(:subject) { HTTPTester.new }

  describe ".connection" do
    it "should create a Faraday object" do
      subject.site = "http://example.com/"
      subject.connection.class.should eql(Faraday::Connection)
    end

    it "should raise Configuration error if site nil" do
      expect {
        subject.connection
      }.to raise_error(Rapidash::ConfigurationError)
    end

    it "should use the site variable if set" do
      Faraday.should_receive(:new).with("http://example.com/")
      subject.site = "http://example.com/"
      subject.connection
    end
  end

  describe ".request" do

    before(:each) do
      subject.site = "http://example.com"
    end

    describe "authorization" do
      let!(:subject) { HTTPTester.new(:login => "login", :password => "password") }

      it "should delegate to Faraday's basic auth" do
        expect(subject.connection.builder.handlers).to include(Faraday::Request::BasicAuthentication)
      end
    end

    describe "without authorization" do
      let!(:subject) { HTTPTester.new() }

      it "should delegate to Faraday's basic auth" do
        expect(subject.connection.builder.handlers).to_not include(Faraday::Request::BasicAuthentication)
      end
    end

    it "should call response" do
      response = double(:body => "response")
      subject.connection.should_receive(:run_request).with(:get, "http://example.com/foo", nil, nil).and_return(response)
      subject.request(:get, "foo")
    end
  end
end
