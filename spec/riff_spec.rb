# frozen_string_literal: true

RSpec.describe(Riff) do
  it "has a version number" do
    expect(Riff::VERSION).not_to(be(nil))
  end

  it "does something useful" do
    expect(Riff::VERSION).not_to(be_nil)
  end
end
