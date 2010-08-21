require 'spec_helper'
require 'pith/project'

describe Pith::Project do
  
  before do
    $input_dir.mkpath
    @project = Pith::Project.new(:input_dir => $input_dir)
  end

  describe "#input" do

    describe "(with a non-template input path)" do

      before do
        @input_file = $input_dir + "input.txt"
        @input_file.touch
      end

      it "constructs an Verbatim object" do
        @input = @project.input("input.txt")
        @input.should be_kind_of(Pith::Input::Verbatim)
        @input.file.should == @input_file
      end

      it "returns the same Input output every time" do
        first_time = @project.input("input.txt")
        second_time = @project.input("input.txt")
        second_time.should equal(first_time)
      end
      
    end

    describe "(with a template input path)" do

      before do
        @input_file = $input_dir + "input.html.haml"
        @input_file.touch
      end

      it "constructs an Template object" do
        @input = @project.input("input.html.haml")
        @input.should be_kind_of(Pith::Input::Template)
        @input.file.should == @input_file
      end
      
    end

    describe "(with a template ouput path)" do
      
      before do
        @input_file = $input_dir + "input.html.haml"
        @input_file.touch
      end

      it "can also be used to locate the Template" do
        @project.input("input.html").should == @project.input("input.html.haml")
      end
      
    end

    describe "(with an invalid input path)" do
      
      it "complains" do
        lambda do
          @project.input("bogus.path")
        end.should raise_error(Pith::ReferenceError)
      end
      
    end
    
  end
  
end
