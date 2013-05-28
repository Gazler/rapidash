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
      let!(:options) { { :login => "login", :password => "password" } }
      let!(:subject) { HTTPTester.new(options) }

      it "should authorize with login and password" do
        subject.connection.should_receive(:basic_auth).with(options[:login], options[:password])
        subject.connection.stub_chain('app.call').and_return("response")
        subject.request(:get, "foo")
      end
    end

    it "should call response" do
      subject.connection.should_receive(:run_request).with(:get, "http://example.com/foo", nil, nil).and_return("response")
      subject.request(:get, "foo")
    end
  end
end
