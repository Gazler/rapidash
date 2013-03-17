require "spec_helper"

class HTTPTester
  include Rapidash::HTTPClient
end

class HTTPSiteTester < HTTPTester
  site "http://mysite.com/"
end

class HTTPExtensionTester < HTTPTester
  site "http://mysite.com/"
  def self.url_extension 
    :json
  end
end

class HTTPErrorTester < HTTPTester
  def self.raise_error
    true
  end
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

    it "should use the site variable if set" do
      Faraday.should_receive(:new).with("http://example.com/")
      subject.site = "http://example.com/"
      subject.connection
    end

    it "should use the class URL if one is defined" do
      subject = HTTPSiteTester.new
      Faraday.should_receive(:new).with("http://mysite.com/")
      subject.connection
    end
  end

  describe ".request" do

    let!(:valid_response) { OpenStruct.new(:status => "200")}
    let!(:redirect_response) { OpenStruct.new(:status => "301", :headers => {"location" => "http://example.com/redirect"})}
    let!(:error_response) { OpenStruct.new(:status => "404")}

    before(:each) do
      subject.site = "http://example.com"
    end

    describe "authorization" do
      let!(:options) { { :login => "login", :password => "password" } }
      let!(:subject) { HTTPTester.new options }

      it "should authorize with login and password" do
        subject.connection.should_receive(:basic_auth).with(options[:login], options[:password])
        subject.connection.stub_chain('app.call').and_return(valid_response)
        subject.request(:get, "foo")
      end
    end

    describe "valid response" do

      before(:each) do
        Rapidash::Response.should_receive(:new).and_return("response")
      end
        
      it "should add an extension if one is set" do
        subject.extension = :json
        subject.connection.should_receive(:run_request).with(:get, "http://example.com/foo.json", nil, nil).and_return(valid_response)
        subject.request(:get, "foo")
      end

      it "should use the class extension if one is set" do
        subject = HTTPExtensionTester.new
        subject.connection.should_receive(:run_request).with(:get, "http://mysite.com/foo.json", nil, nil).and_return(valid_response)
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

    describe "error response" do
      
      it "should not raise an error by default" do
          subject.connection.should_receive(:run_request).with(:get, "http://example.com/error", nil, nil).and_return(error_response)
          response = subject.request(:get, "error")
          response.should be_nil
      end

      it "should raise an error if the option is set" do
          subject = HTTPErrorTester.new
          subject.connection.should_receive(:run_request).with(:get, anything, nil, nil).and_return(error_response)
          expect {
            response = subject.request(:get, "error")
          }.to raise_error(Rapidash::ResponseError)
      end

    end
  end
end
