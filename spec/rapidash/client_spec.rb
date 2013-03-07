require 'spec_helper'

describe Rapidash::Client do
  it "should raise an error when instantiated" do
    expect {
     Rapidash::Client.new
    }.to raise_error(Rapidash::ConfigurationError)
  end
end
