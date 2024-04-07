require "spec"
require "../src/agregator"

describe Array do

  it "return true if self starts with prefix" do
    ["abc", "de", "fghi"].starts_with(["abc", "de"]).should eq true
  end

  it "return false if self does not starts with prefix" do
    ["abc", "de", "fghi"].starts_with(["abc", "fg"]).should eq false
  end

  it "return false if prefix too long" do
    ["abc", "de", "fghi"].starts_with(["abc", "de", "fghi", "jkl"]).should eq false
  end

  it "return true if prefix is empty" do
    ["abc", "de", "fghi"].starts_with([] of String).should eq true
  end


end
