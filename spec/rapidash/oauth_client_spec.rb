require 'spec_helper'

class OAuthTester
  include Rapidash::OAuthClient
end

class OAuthErrorTester < OAuthTester
  def self.raise_error
    true
  end
end

describe Rapidash::OAuthClient do

  before(:each) do
    Rapidash::Response.stub(:new).and_return(Hashie::Mash.new)
  end

  let(:options) {
    {
      :uid => "foo",
      :secret => "bar",
      :access_token => "baz",
      :site => "http://example.com"
    }
  }

  let(:subject) { OAuthTester.new(options) }

  describe ".initialize" do

    it "should not raise an error with the correct options" do
      expect {
        OAuthTester.new(options)
      }.to_not raise_error(Rapidash::ConfigurationError)
    end

    it "should raise an error if the correct options are not set" do
      expect {
        OAuthTester.new({})
      }.to raise_error(Rapidash::ConfigurationError)
    end
  end


 describe ".access_token_from_code" do
    it "should call localhost for the access token" do
      auth_code = mock
      client = mock
      subject.stub(:client).and_return(client)
      client.should_receive(:auth_code).and_return(auth_code)
      auth_code.should_receive(:get_token).with("123", :redirect_uri => "http://localhost").and_return(OpenStruct.new(:token => "token"))
      subject.access_token_from_code("123", "http://localhost").should eql("token")
    end
  end

  describe ".client" do
    it "should be an OAuth2::Client" do
      subject.send(:client).class.should eql(OAuth2::Client)
    end
  end

  describe ".oauth_access_token" do
    it "should be an OAuth2::AccessToken" do
      subject.send(:oauth_access_token).class.should eql(OAuth2::AccessToken)
    end
  end

  describe ".request" do

    let(:request) { mock }

    describe "object returned from API call" do

      before(:each) do
        subject.stub(:oauth_access_token).and_return(request)
        subject.stub(:normalize_url).with("me").and_return("me")
        request.stub(:get)
      end

      it "should return a Hashie::Mash" do
        subject.request(:get, "me").class.should eql(Hashie::Mash)
      end

    end

    describe "when errors are set" do
      it "should call oauth_access_token.send with errors set" do
        subject = OAuthErrorTester.new(options)
        subject.stub(:normalize_url).and_return("error")
        subject.stub(:oauth_access_token).and_return(request)
        request.should_receive(:send).with(:get, "http://example.com/error", {:raise_errors => true})
        subject.request(:get, "error")
      end
      
    end

    describe "when a body is set" do
      it "should call oauth_access_token.send with errors set" do
        subject.stub(:normalize_url).and_return("users")
        subject.stub(:oauth_access_token).and_return(request)
        request.should_receive(:send).with(:get, "http://example.com/users", {:body => {"foo" => "bar"}.to_json, :raise_errors => false})
        subject.request(:get, "error", :body => {"foo" => "bar"})
      end
      
    end


  end
end

