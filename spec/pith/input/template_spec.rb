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
  
  describe ".can_handle?" do
    
    it "returns true for template paths" do
      Pith::Input::Template.can_handle?("xyz.html.haml").should be_true
      Pith::Input::Template.can_handle?("xyz.html.md").should be_true
    end

    it "handles directories" do
      Pith::Input::Template.can_handle?("dir/xyz.haml").should be_true
    end

    it "accepts Pathname objects" do
      Pith::Input::Template.can_handle?(Pathname("xyz.html.haml")).should be_true
    end

    it "returns false for non-template paths" do
      Pith::Input::Template.can_handle?("foo.html").should be_false
      Pith::Input::Template.can_handle?("foo").should be_false
    end
    
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
