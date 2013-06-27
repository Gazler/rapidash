require 'spec_helper'

describe Faraday::Response::RaiseRapidashError do
  context "successful response" do
    let(:env) { { :status => '200' } }

    it "should not raise an exception" do
      expect {
        subject.on_complete(env)
      }.to_not raise_exception(Rapidash::ResponseError)
    end
  end

  context "error response" do
    let(:env) { { :status => '404', :method => 'post', :url => 'http://acme.com/api/posts' } }

    it "should raise an exception" do
      expect {
        subject.on_complete(env)
      }.to raise_exception(Rapidash::ResponseError)
    end

    describe "custom reponse error" do
      before :each do
        class MyCustomResponseError < Rapidash::ResponseError; end
        Rapidash.response_exception_class = MyCustomResponseError
      end

      it "should raise a custom excpetion class if specified" do
        expect {
          subject.on_complete(env)
        }.to raise_exception(MyCustomResponseError)
      end

      after :each do
        Rapidash.response_exception_class = nil
      end
    end
  end
end
