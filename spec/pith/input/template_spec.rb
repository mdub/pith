require 'spec_helper'
require "pith/input/abstract"
require "pith/project"

describe Pith::Input::Template do

  before do
    $input_dir.mkpath
    @project = Pith::Project.new(:input_dir => $input_dir)
  end

  def make_input(path)
    input_file = $input_dir + path
    input_file.parent.mkpath
    input_file.open("w") do |io|
      yield io if block_given?
    end
    @project.input(path)
  end
  
  describe "#title" do
    
    it "is based on last component of filename" do
      @input = make_input("dir/some_page.html.haml")
      @input.title.should == "Some page"
    end

    it "can be over-ridden in metadata" do
      @input = make_input("dir/some_page.html.haml") do |i|
        i.puts "---"
        i.puts "title: Blah blah"
        i.puts "..."
      end
      @input.title.should == "Blah blah"
    end
  
  end

  describe "#output_path" do
    
    it "excludes the template-type extension" do
      @input = make_input("dir/some_page.html.haml")
      @input.output_path.should == Pathname("dir/some_page.html")
    end
    
  end
  
end
