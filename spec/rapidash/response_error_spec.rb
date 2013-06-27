require 'spec_helper'

class MyCustomResponseError < Rapidash::ResponseError
  def errors
    if body.kind_of?(Array)
      body.join(', ')
    else
      body
    end
  end
end

describe Rapidash::ResponseError do

  context "standard response error class" do
    let(:response) { Rapidash::ResponseError.new(env) }
    let(:env) { { :status => '404', :method => 'post', :url => 'http://acme.com/api/posts', :body => 'Page not found' } }

    describe ".initialize" do
      it "should set attributes" do
        expect(response.status).to eq 404
        expect(response.method).to eq 'POST'
        expect(response.url).to eq 'http://acme.com/api/posts'
        expect(response.body).to eq 'Page not found'
      end
    end

    describe "#message" do
      it "should create a formatted error message" do
        message = response.send(:message)
        expect(message).to eq '404 POST http://acme.com/api/posts'
      end
    end
  end

  context "custom error class with #errors method" do
    before :each do
      Rapidash.response_exception_class = MyCustomResponseError
    end

    let(:response) { MyCustomResponseError.new(env) }
    let(:env) { { :status => '404', :method => 'post', :url => 'http://acme.com/api/posts', :body => ['name cannot be blank', 'content cannot be blank'] } }

    it "should call #errors" do
      response.should_receive(:errors)
      response.send(:message)
    end

    it "should create a formatted error message" do
      message = response.send(:message)
      expect(message).to eq '404 POST http://acme.com/api/posts | Errors: name cannot be blank, content cannot be blank'
    end

    after :each do
      Rapidash.response_exception_class = nil
    end

  end
end
