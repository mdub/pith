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
        @input_path = $input_dir + "input.txt"
        @input_path.touch
      end

      it "constructs an Verbatim object" do
        @input = @project.input("input.txt")
        @input.should be_kind_of(Pith::Input::Verbatim)
        @input.full_path.should == @input_path
      end

      it "returns the same Input output every time" do
        first_time = @project.input("input.txt")
        second_time = @project.input("input.txt")
        second_time.should equal(first_time)
      end
      
    end

    describe "(with a template input path)" do

      before do
        @input_path = $input_dir + "input.haml"
        @input_path.touch
      end

      it "constructs an Template object" do
        @input = @project.input("input.haml")
        @input.should be_kind_of(Pith::Input::Template)
        @input.full_path.should == @input_path
      end
      
    end

    describe "(with an invalid input path)" do
      
      it "complains" do
        lambda do
          @project.input("bogus.path")
        end.should raise_error
      end
      
    end
    
  end
  
end
