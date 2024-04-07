require "spec"
require "../src/loader"

describe Loader do

  it "loads single YAML file" do
    loader = Loader.new
    birthdays = loader.load_file("example/data/anniv/birthdays.yaml")
    birthdays[0].as_h.should eq ({"02/11" => "Thomas Edison"})
    birthdays[1].as_h.should eq ({"02/18" => "Alessandro Volta"})
    birthdays[2].as_h.should eq ({"02/18" => "Ernst Mach"})
  end

  it "loads directory with YAML files recursively" do
    loader = Loader.new
    example = loader.load_dir("example/data")
    example.as_h.keys.should eq ["anniv", "home", "vacations", "work"]
    example["anniv"]["birthdays"][2].as_h.should eq ({"02/18" => "Ernst Mach"})
    example["home"]["cleaning"]["mon"].should eq "garden"
  end

end
