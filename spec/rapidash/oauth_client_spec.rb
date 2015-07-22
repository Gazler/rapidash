require 'spec_helper'

class OAuthTester < Rapidash::Client
  include Rapidash::OAuthClient
end

class OAuthErrorTester < OAuthTester
  def self.raise_error
    true
  end
end

describe Rapidash::OAuthClient do
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
      }.to_not raise_error
    end

    it "should raise an error if the correct options are not set" do
      expect {
        OAuthTester.new({})
      }.to raise_error(Rapidash::ConfigurationError)
    end
  end


 describe ".access_token_from_code" do
    it "should call localhost for the access token" do
      auth_code = double
      client = double
      allow(subject).to receive(:client).and_return(client)
      expect(client).to receive(:auth_code).and_return(auth_code)
      expect(auth_code).to receive(:get_token).with("123", :redirect_uri => "http://localhost").and_return(OpenStruct.new(:token => "token"))
      expect(subject.access_token_from_code("123", "http://localhost")).to eql("token")
    end
  end

  describe ".client" do
    it "should be an OAuth2::Client" do
      expect(subject.send(:client).class).to eql(OAuth2::Client)
    end
  end

  describe ".oauth_access_token" do
    it "should be an OAuth2::AccessToken" do
      expect(subject.send(:oauth_access_token).class).to eql(OAuth2::AccessToken)
    end
  end

  describe ".request" do
    let(:request) { double(:body => 'data') }

    describe "object returned from API call" do
      before(:each) do
        allow(subject).to receive(:oauth_access_token).and_return(request)
        allow(subject).to receive(:normalize_url).with("me").and_return("me")
        allow(request).to receive(:get) { request }
      end

      it "should return a Hashie::Mash" do
        expect(subject.request(:get, "me")).to eq 'data'
      end
    end
  end
end

