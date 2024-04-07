require "spec"
require "../src/parser"

describe "parse_digits" do

  it "parse JSON small integer as day" do
      parse_digits("10").should eq SpecTriple.new(nil, nil, 10)
  end

  it "parse JSON big integer as year" do
      parse_digits("2022").should eq SpecTriple.new(2022, nil, nil)
  end

  it "parse JSON small float as month.day" do
      parse_digits("10/22").should eq SpecTriple.new(nil, 10, 22)
  end

  it "parse JSON big float as year.month" do
      parse_digits("2022/10").should eq SpecTriple.new(2022, 10, nil)
  end

  it "parse JSON string as year.month.day" do
      parse_digits("2022/10/22").should eq SpecTriple.new(2022, 10, 22)
  end

  it "raises on too many digits" do
    expect_raises(ParseTripleError, "Too many digits: \"1/2/3/4\"") do
      parse_digits("1/2/3/4")
    end
  end

  it "raises on non-numbers" do
    expect_raises(ParseTripleError, "Invalid integers: \"1/x/3\"") do
      parse_digits("1/x/3")
    end
  end

end

describe "parse_literal" do

  it "parse month" do
      parse_literal("jn").should eq SpecTriple.new(nil, 6, nil)
      parse_literal("jun").should eq SpecTriple.new(nil, 6, nil)
      parse_literal("jul").should eq SpecTriple.new(nil, 7, nil)
  end

  it "parse weekdays" do
      parse_literal("mo").should eq SpecWeekday.new(1)
      parse_literal("wed").should eq SpecWeekday.new(3)
      parse_literal("sunday").should eq SpecWeekday.new(7)
  end

  it "parse special" do
      parse_literal("daily").should eq SpecRange.new(nil, nil)
  end

  it "raises on unknown word" do
    expect_raises(ParseLiteralError, "Unknown literal: \"foobar\"") do
      parse_literal("foobar")
    end
  end

end

describe "parse_prefix" do

  it "parse month" do
      parse_prefix("m4").should eq SpecTriple.new(nil, 4, nil)
  end

  it "parse quarter" do
      parse_prefix("q2").should eq SpecRange.new(SpecTriple.new(nil, 4, 1), SpecTriple.new(nil, 6, 30))
  end

  it "raises on unknown prefix" do
    expect_raises(ParsePrefixError, "Unknown prefix: \"x1\"") do
      parse_prefix("x1")
    end
  end

end

describe "parse_range" do

  it "parse daily" do
    parse_range("-").should eq SpecRange.new(nil, nil)
  end

  it "parse from a day to infinity" do
    parse_range("5-").should eq SpecRange.new(SpecTriple.new(nil, nil, 5), nil)
  end

  it "parse from minus infinity to a day" do
    parse_range("-5").should eq SpecRange.new(nil, SpecTriple.new(nil, nil, 5))
  end

  it "raise when there is more than one range operator" do
    expect_raises(ParseRangeError, "Too many range operators: \"--\"") do
      parse_range("--").should eq SpecRange.new(nil, SpecTriple.new(nil, nil, 5))
    end
  end


end

describe "parse_spec" do

  it "parse negation" do
    parse_spec("!5").should eq SpecNot.new(SpecTriple.new(nil, nil, 5))
  end

  it "parse alternative" do
    parse_spec("5,wed").should eq SpecOr.new([SpecTriple.new(nil, nil, 5), SpecWeekday.new(3)])
  end

  it "parse conjunction" do
    parse_spec("5 wed").should eq SpecAnd.new([SpecTriple.new(nil, nil, 5), SpecWeekday.new(3)])
  end

  it "parse ucase" do
    parse_spec("Wed").should eq SpecWeekday.new(3)
  end

  it "parse mixed" do
    parse_spec("5 1,wed").should eq \
      SpecAnd.new([SpecTriple.new(nil, nil, 5), SpecOr.new([SpecTriple.new(nil, nil, 1), SpecWeekday.new(3)])])
  end

end




