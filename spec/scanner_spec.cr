require "spec"
require "yaml"
require "../src/loader"
require "../src/scanner"

describe Scanner do

  it "reads sample dir structure" do
    loader = Loader.new
    tree = loader.load_dir("example/data")
    scanner = Scanner.new
    scanner.scan(tree)
    scanner.@generators[ ["anniv", "birthdays", "Ernst Mach"] ].should eq ["02/18"]
    scanner.@generators[ ["home", "cleaning", "garden"] ].should eq ["mon"]
    scanner.@generators[ ["vacations", "public", "Labour Day"] ].should eq ["2024/05/01"]
    scanner.@generators[ ["vacations", "welness"] ].should eq ["2024/02/02", "2024/03/15", "2024/05/10", "2024/07/12", "2024/10/18"]
    scanner.@generators[ ["work", "meetings", "15:15 Sprint Planning"] ].should eq ["wed"]
  end

  it "raises on invalid branch" do
    tree = YAML.parse("{1: 2}")
    scanner = Scanner.new
    expect_raises(ScanningError, "Incorrect branch: \"/1/2\"") do
      scanner.scan(tree)
    end
  end

  it "raises on invalid key" do
    tree = YAML.parse("{[1]: 2}")
    scanner = Scanner.new
    expect_raises(ScanningError, "Incorrect key: [1]") do
      scanner.scan(tree)
    end
  end

end

