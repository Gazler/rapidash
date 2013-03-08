require "spec_helper"

class TestClientTester
  include Rapidash::TestClient
end

describe Rapidash::HTTPClient do

  let!(:responses) { 
    {
      :get => {
        "foo" => "response"
      }
    } 
  }

  let!(:subject) { TestClientTester.new(:responses => responses) }

  describe ".get" do
    it "should call request" do
      subject.should_receive(:request).with(:get, "foo", {})
      subject.get("foo")
    end
  end

  describe ".get" do
    it "should call request" do
      subject.should_receive(:request).with(:post, "foo", {})
      subject.post("foo")
    end
  end

  describe ".request" do
    it "should do something" do
      Rapidash::Response.should_receive(:new).with("response")
      subject.request(:get, "foo")
    end
  end

end
