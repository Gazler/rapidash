require "spec_helper"

class TesterClient
  include Rapidash::TestClient
end

describe Rapidash::TestClient do
  let(:responses) do
    { :get => { "foo" => "bar" } }
  end

  let(:client) { TesterClient.new(responses) }

  describe ".new" do
    let(:stubs) { client.stubs }

    it "should create Faraday test stubs" do
      expect(stubs).to be_a Faraday::Adapter::Test::Stubs
    end
  end

  describe "#request" do
    let(:response) { client.request(:get, '/foo') }

    it "should respond with the correct data" do
      expect(response).to eq 'bar'
    end
  end
end
