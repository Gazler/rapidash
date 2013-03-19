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
        subject.should_receive(:process_response).with("response", :get, {})
        subject.connection.should_receive(:basic_auth).with(options[:login], options[:password])
        subject.connection.stub_chain('app.call').and_return("response")
        subject.request(:get, "foo")
      end
    end

    it "should call response" do
        subject.should_receive(:process_response).with("response", :get, {})
      subject.connection.should_receive(:run_request).with(:get, "http://example.com/foo", nil, nil).and_return("response")
        subject.request(:get, "foo")
    end
  end

  describe ".process_response" do

    let!(:valid_response) { OpenStruct.new(:status => "200")}
    let!(:redirect_response) { OpenStruct.new(:status => "301", :headers => {"location" => "http://example.com/redirect"})}
    let!(:error_response) { OpenStruct.new(:status => "404")}

    before(:each) do
      subject.site = "http://example.com"
    end

    describe "valid response" do
      before(:each) do
        Rapidash::Response.should_receive(:new).and_return("response")
      end
        
      it "should return a response object" do
        response = subject.process_response(valid_response, :get, {})
        response.should eql("response")
      end

      it "should perform a redirect" do
        subject.should_receive(:request).with(:get, "http://example.com/redirect", anything).and_return(subject.process_response(valid_response, :get, {}))
        response = subject.process_response(redirect_response, :get, {})
        response.should eql("response")
      end
    end

    describe "error response" do
      it "should not raise an error by default" do
        response = subject.process_response(error_response, :get, {})
        response.should be_nil
      end

      it "should raise an error if the option is set" do
          subject = HTTPErrorTester.new
          expect {
            response = subject.process_response(error_response, :get, {})
          }.to raise_error(Rapidash::ResponseError)
      end

    end
  end
end
