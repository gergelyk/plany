require "spec"
require "../src/parser"


def date(year, month, day)
  Time.utc(year, month, day, 0, 0, 0)
end

def meets(spec, num_days, start_date=nil)
  start_date = start_date.nil? ? date(2022, 1, 1) : start_date
  spec_obj = parse_spec(spec)
  covered_dates = [] of String
  num_days.times do |delta|
    date = start_date + delta.days
    if spec_obj.covers?(date)
      covered_dates << date.to_s("%Y/%m/%d")
    end
  end
  return covered_dates
end



describe "SpecTriple" do

  it "covers exact day of each month each year" do
    meets("5", 50).should eq [
      "2022/01/05",
      "2022/02/05",
    ]
  end

  it "covers exact month each year" do
    meets("m5", 340, date(2022, 5, 28)).should eq [
      "2022/05/28",
      "2022/05/29",
      "2022/05/30",
      "2022/05/31",
      "2023/05/01",
      "2023/05/02",
    ]
  end

  it "covers exact year" do
    meets("2023", 7, date(2022, 12, 28)).should eq [
      "2023/01/01",
      "2023/01/02",
      "2023/01/03",
    ]
  end

  it "covers exact month and day every year" do
    meets("01/15", 400).should eq [
      "2022/01/15",
      "2023/01/15",
    ]
  end

  it "covers exact month and year" do
    meets("2022/2", 35).should eq [
      "2022/02/01",
      "2022/02/02",
      "2022/02/03",
      "2022/02/04",
    ]
  end

  it "covers exact date" do
    meets("2022/2/3", 35).should eq [
      "2022/02/03",
    ]
  end


end

describe "SpecWeekday" do

  it "covers exact day each week" do
    meets("wed", 15).should eq [
      "2022/01/05",
      "2022/01/12",
    ]
  end

end


describe "SpecNot" do

  it "covers remaining days each week" do
    meets("!mon", 5).should eq [
      "2022/01/01",
      "2022/01/02",
      "2022/01/04",
      "2022/01/05",
    ]
  end

end


describe "SpecAnd" do

  it "covers exact day of exact year" do
    meets("2022 2/10", 500).should eq [
      "2022/02/10",
    ]
  end

end

describe "SpecOr" do

  it "covers exact days each week" do
    meets("mon,wed", 15).should eq [
      "2022/01/03",
      "2022/01/05",
      "2022/01/10",
      "2022/01/12",
    ]
  end

end


describe "SpecRange" do

  it "covers a few days of the same month" do
    meets("2022/01/03-06", 15).should eq [
      "2022/01/03",
      "2022/01/04",
      "2022/01/05",
      "2022/01/06",
    ]
  end

  it "covers a few days across two months" do
    meets("2022/01/28-02/02", 60).should eq [
      "2022/01/28",
      "2022/01/29",
      "2022/01/30",
      "2022/01/31",
      "2022/02/01",
      "2022/02/02",
    ]
  end

  it "covers a few days across two years" do
    meets("2022/12/28-2023/01/02", 500).should eq [
      "2022/12/28",
      "2022/12/29",
      "2022/12/30",
      "2022/12/31",
      "2023/01/01",
      "2023/01/02",
    ]
  end

  it "covers a few days after given" do
    meets("2022/01/03-", 5).should eq [
      "2022/01/03",
      "2022/01/04",
      "2022/01/05",
    ]
  end

  it "covers a few days before given" do
    meets("-2022/01/03", 5).should eq [
      "2022/01/01",
      "2022/01/02",
      "2022/01/03",
    ]
  end

end


