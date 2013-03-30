require 'spec_helper'

class BaseTester < Rapidash::Base
  url "tester"
end

class Base < Rapidash::Base
end

class Rapidash::Resource < Rapidash::Base
end

class BaseTesterClient
  class << self
    attr_accessor :patch
  end
end

class RootTester < Rapidash::Base
  root :post
end


describe Rapidash::Base do

  describe ".initialize" do

    it "should assume a default based on the class name" do
      Base.new.instance_variable_get(:@url).should eql("bases")
    end

    it "should ignore any modules when infering the URL" do
      Rapidash::Resource.new.instance_variable_get(:@url).should eql("resources")
    end

    it "should override the URL if set" do
        BaseTester.new.instance_variable_get(:@url).should eql("tester")
    end
  end

  let(:client) { BaseTesterClient.new }
  let(:headers) { {"content-type" => "application/json"} }
  let(:subject) { BaseTester.new(client) }

  let(:no_root) {
    {
      :title => "A test post"
    }
  }

  let(:post) {
    {
      :post => no_root
    }
  }

  describe ".create!" do
    it "should set the method to post and set the body" do
      subject.should_receive(:call!)
      subject.create!(post)
      subject.instance_variable_get(:@options).should eql({
        :method => :post,
        :body => post
      })
    end

    it "should use the root element if one is defined" do
      subject = RootTester.new
      subject.should_receive(:call!)
      subject.create!(no_root)
      subject.instance_variable_get(:@options).should eql({
        :method => :post,
        :body => post
      })
    end
  end

  describe ".update!" do
    it "should set the method to put and set the body" do
      subject.should_receive(:call!)
      subject.update!(post)
      subject.instance_variable_get(:@options).should eql({
        :method => :put,
        :body => post
      })
    end

    it "should use the patch verb if set on the client" do
      client.class.patch = true
      subject.should_receive(:call!)
      subject.update!(post)
      subject.instance_variable_get(:@options).should eql({
        :method => :patch,
        :body => post
      })
    end

    it "should use the root element if one is defined" do
      subject = RootTester.new(client)
      subject.should_receive(:call!)
      subject.update!(no_root)
      subject.instance_variable_get(:@options).should eql({
        :method => :patch,
        :body => post
      })
    end
  end

  describe ".delete!" do
    it "should set the method to delete" do
      subject.should_receive(:call!)
      subject.delete!
      subject.instance_variable_get(:@options).should eql({:method => :delete})
    end
    
  end

  describe ".call!" do
    it "should call get on the client" do
      subject.url = "tester/1"
      client.should_receive(:get).with("tester/1", {:headers => headers})
      subject.call!
    end


    it "should call a post on the client if set" do
      client.should_receive(:post).with("tester", {:headers => headers})
      subject.options = {:method => :post}
      subject.url = "tester"
      subject.call!
    end
  end

  describe ".base_url" do
    it "should return an empty string if no previous url is set" do
      subject.send(:base_url).should eql("")
    end

    it "should return the previous url if set" do
      subject.options = {:previous_url => "users/Gazler"}
      subject.send(:base_url).should eql("users/Gazler/")
    end
  end

  describe ".resource_url" do
    it "should return the class name as a url if none is specified" do
      subject.send(:resource_url).should eql("basetesters")
    end

    it "should return the previous url if set" do
      subject.options = {:url => "people"}
      subject.send(:resource_url).should eql("people")
    end
  end


end
