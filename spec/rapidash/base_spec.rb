require 'spec_helper'

class BaseTester < Rapidash::Base
  url "tester"
end

class Base < Rapidash::Base
end

class Rapidash::Resource < Rapidash::Base
end


describe Rapidash::Base do

  describe ".initialize" do

    it "should assume a default based on the class name" do
      Base.new.instance_variable_get(:@url).should eql("base")
    end

    it "should ignore any modules when infering the URL" do
      Rapidash::Resource.new.instance_variable_get(:@url).should eql("resource")
    end

    it "should override the URL if set" do
        BaseTester.new.instance_variable_get(:@url).should eql("tester")
    end
  end

  let(:client) { mock }
  let(:headers) { {"content-type" => "application/json"} }
  let (:subject) { BaseTester.new(client) }

  describe ".call!" do
    it "should call get on the client" do
      subject.url = "tester/1"
      client.should_receive(:get).with("tester/1", {:header => headers})
      subject.call!
    end


    it "should call a post on the client if set" do
      client.should_receive(:post).with("tester", {:header => headers})
      subject.options = {:method => :post}
      subject.url = "tester"
      subject.call!
    end
  end

end
