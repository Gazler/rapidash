require 'spec_helper'

class Client < Rapidash::Client
  method :test
end

describe Rapidash::Client do

  let!(:subject) { Client.new }

  it "should raise an error when instantiated" do
    expect {
     Rapidash::Client.new
    }.to raise_error(Rapidash::ConfigurationError)
  end

  describe ".get" do
    it "should call request" do
      subject.should_receive(:request).with(:get, "foo", {})
      subject.get("foo")
    end
  end

  describe ".post" do
    it "should call request" do
      subject.should_receive(:request).with(:post, "foo", {})
      subject.post("foo")
    end
  end

end
