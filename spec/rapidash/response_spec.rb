require 'json'
require "spec_helper"

def valid_response_object
  body = {"foo" => "bar" }.to_json
  OpenStruct.new({
    :headers => {
      "content-type" => "application/json"
    },
    :body => body
  })
end

def valid_html_response_object
  body = {"foo" => "bar" }.to_json
  OpenStruct.new({
    :headers => {
      "content-type" => "text/html"
    },
    :body => body
  })
end

def valid_js_response_object
  body = {"foo" => "bar" }.to_json
  OpenStruct.new({
    :headers => {
      "content-type" => "text/javascript"
    },
    :body => body
  })
end


def valid_response_array
  body = [{"foo" => "bar" }, {"baz" => "bra"}].to_json
  OpenStruct.new({
    :headers => {
      "content-type" => "application/json"
    },
    :body => body
  })
end


def invalid_response
  OpenStruct.new({
    :headers => {
      "content-type" => "application/xml"
    },
    :body => "<xml>something</xml>"
  })
end

def invalid_js_response_object
  OpenStruct.new({
    :headers => {
      "content-type" => "text/javascript"
    },
    :body => "<xml>something</xml>"
  })
end

def nil_response
  OpenStruct.new({
    :body => nil
  })
end

describe Rapidash::Response do

  describe "#new" do
    it "should parse JSON Objects" do
      response = Rapidash::Response.new(valid_response_object)
      response.foo.should eql("bar")
    end
    
    it "should parse JSON Objects returned with javascript type" do
      response = Rapidash::Response.new(valid_js_response_object)
      response.foo.should eql("bar")
    end
    
    it "should parse JSON Objects returned with html type" do
      response = Rapidash::Response.new(valid_html_response_object)
      response.foo.should eql("bar")
    end        

    it "should parse JSON Arrays" do
      response = Rapidash::Response.new(valid_response_array)
      response[0].foo.should eql("bar")
      response[1].baz.should eql("bra")
    end

    it "should return nil if the response has no body" do
      response = Rapidash::Response.new(nil_response)
      response.should eql(nil)
    end


    it "should raise an error on a non-json response" do
      expect {
        Rapidash::Response.new(invalid_response)
      }.to raise_error(Rapidash::ParseError)
    end
    
    it "should raise an error on a non-json response body" do
      expect {
        Rapidash::Response.new(invalid_js_response_object)
      }.to raise_error(Rapidash::ParseError)
    end    
  end


end
