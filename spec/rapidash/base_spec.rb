require 'spec_helper'

class BaseTester < Rapidash::Base
  url "tester"
end

class InvalidApiTester < Rapidash::Base
end


describe Rapidash::Base do

  describe ".initialize" do

    it "should raise an error" do
      expect {
        InvalidApiTester.new
      }.to raise_error(Rapidash::ConfigurationError)
    end

    it "should not raise an error if url has been called" do
      expect {
        BaseTester.new.should be_valid
      }.to_not raise_error(Rapidash::ConfigurationError)
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
