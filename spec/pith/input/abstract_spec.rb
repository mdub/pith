require 'spec_helper'
require "pith/input/abstract"
require "pith/project"

describe Pith::Input::Abstract do

  before do
    $input_dir.mkpath
    @project = Pith::Project.new(:input_dir => $input_dir)
    @input_file = $input_dir + "some_page.html.haml"
    @input_file.touch
  end
      
  describe "#title" do
    
    it "is based on last component of filename" do
      @project.input("some_page.html").title.should == "Some page"
    end

    it "can be over-ridden in metadata" do
      @input_file.open("w") do |i|
        i.puts "---"
        i.puts "title: Blah blah"
        i.puts "..."
      end
      @project.input("some_page.html").title.should == "Blah blah"
    end
  
  end
  
end
