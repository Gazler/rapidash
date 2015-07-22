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
      expect(Base.new.instance_variable_get(:@url)).to eql("bases")
    end

    it "should ignore any modules when infering the URL" do
      expect(Rapidash::Resource.new.instance_variable_get(:@url)).to eql("resources")
    end

    it "should override the URL if set" do
        expect(BaseTester.new.instance_variable_get(:@url)).to eql("tester")
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
      allow(subject).to receive(:call!)
      subject.create!(post)
      expect(subject.instance_variable_get(:@options)).to eql({
        :method => :post,
        :body => post
      })
    end

    it "should use the root element if one is defined" do
      subject = RootTester.new
      allow(subject).to receive(:call!)
      subject.create!(no_root)
      expect(subject.instance_variable_get(:@options)).to eql({
        :method => :post,
        :body => post
      })
    end
  end

  describe ".update!" do
    it "should set the method to put and set the body" do
      allow(subject).to receive(:call!)
      subject.update!(post)
      expect(subject.instance_variable_get(:@options)).to eql({
        :method => :put,
        :body => post
      })
    end

    it "should use the patch verb if set on the client" do
      client.class.patch = true
      allow(subject).to receive(:call!)
      subject.update!(post)
      expect(subject.instance_variable_get(:@options)).to eql({
        :method => :patch,
        :body => post
      })
    end

    it "should use the root element if one is defined" do
      subject = RootTester.new(client)
      allow(subject).to receive(:call!)
      subject.update!(no_root)
      expect(subject.instance_variable_get(:@options)).to eql({
        :method => :patch,
        :body => post
      })
    end
  end

  describe ".delete!" do
    it "should set the method to delete" do
      allow(subject).to receive(:call!)
      subject.delete!
      expect(subject.instance_variable_get(:@options)).to eql({:method => :delete})
    end
    
  end

  describe ".call!" do
    it "should call get on the client" do
      subject.url = "tester/1"
      allow(client).to receive(:get).with("tester/1", {:headers => headers})
      subject.call!
    end


    it "should call a post on the client if set" do
      allow(client).to receive(:post).with("tester", {:headers => headers})
      subject.options = {:method => :post}
      subject.url = "tester"
      subject.call!
    end
  end

  describe ".base_url" do
    it "should return an empty string if no previous url is set" do
      expect(subject.send(:base_url)).to eql("")
    end

    it "should return the previous url if set" do
      subject.options = {:previous_url => "users/Gazler"}
      expect(subject.send(:base_url)).to eql("users/Gazler/")
    end
  end

  describe ".resource_url" do
    it "should return the class name as a url if none is specified" do
      expect(subject.send(:resource_url)).to eql("basetesters")
    end

    it "should return the previous url if set" do
      subject.options = {:url => "people"}
      expect(subject.send(:resource_url)).to eql("people")
    end
  end


end
