require "spec"
require "../src/utils"

describe String do

  it "foobar.ltrim 0 gives null string" do
    "foobar".ltrim(0).should eq ""
  end

  it "foobar.ltrim 1 gives ellipsis" do
    "foobar".ltrim(1).should eq "…"
  end

  it "foobar.ltrim 2 gives ...f" do
    "foobar".ltrim(2).should eq "…r"
  end

  it "foobar.ltrim 6 gives foobar" do
    "foobar".ltrim(6).should eq "foobar"
  end

  it "foobar.ltrim 9 gives foobar" do
    "foobar".ltrim(9).should eq "foobar"
  end

  it "empty.ltrim 0 gives null string" do
    "".ltrim(0).should eq ""
  end

  it "empty.ltrim 1 gives null string" do
    "".ltrim(1).should eq ""
  end

  it "empty.ltrim 2 gives null string" do
    "".ltrim(2).should eq ""
  end

  it "x.ltrim 0 gives null string" do
    "x".ltrim(0).should eq ""
  end

  it "x.ltrim 1 gives x" do
    "x".ltrim(1).should eq "x"
  end

  it "x.ltrim 2 gives x" do
    "x".ltrim(2).should eq "x"
  end

end

