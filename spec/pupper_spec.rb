require "spec_helper"

RSpec.describe Pupper do
  it "has a version number" do
    expect(Pupper::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
