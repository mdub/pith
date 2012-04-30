require 'spec_helper'
require 'pith/project'

describe Pith::Project do

  before do
    @project = Pith::Project.new($input_dir, $output_dir)
  end

  describe "#build" do

    before do
      @project.build
    end

    it "creates the output directory" do
      $output_dir.should be_directory
    end

  end

  describe "#input" do

    before do
      @input_file = $input_dir + "input.html.haml"
      @input_file.touch
      @project.sync
    end

    describe "(with a template input path)" do

      it "returns an Input object" do
        @input = @project.input("input.html.haml")
        @input.should be_kind_of(Pith::Input)
        @input.file.should == @input_file
      end

      it "returns the same object the second time" do
        first_time = @project.input("input.html.haml")
        second_time = @project.input("input.html.haml")
        second_time.should equal(first_time)
      end

    end

    describe "(with an invalid input path)" do

      it "returns nil" do
        @project.input("bogus.path").should be_nil
      end

    end

  end

  describe "#output" do

    before do
      @input_file = $input_dir + "input.html.haml"
      @input_file.touch
      @project.sync
    end

    describe "(with a template output path)" do

      let(:output) { @project.output("input.html") }

      it "returns the matching Output" do
        output.should be_kind_of(Pith::Output)
        output.file.should == $output_dir + "input.html"
      end

    end

    describe "(with a bogus output path)" do

      let(:output) { @project.output("bogus.html.haml") }

      it "returns nil" do
        output.should be_nil
      end

    end

  end

  describe "when an input file is removed" do

    before do
      @input_file = $input_dir + "input.html.haml"
      @input_file.touch(Time.now - 10)
      @project.sync
      @project.input("input.html.haml").should_not be_nil
      @project.output("input.html").should_not be_nil
      FileUtils.rm(@input_file)
      @project.sync
    end

    describe "#input" do
      it "returns nil" do
        @project.input("input.html.haml").should be_nil
      end
    end

    describe "#output" do
      it "returns nil" do
        @project.output("input.html").should be_nil
      end
    end

  end

  describe "#ignore_patterns" do

    it "is a set" do
      @project.ignore_patterns.should be_kind_of(Set)
    end

    it "includes some sensible defaults" do
      @project.ignore_patterns.should include("_*")
      @project.ignore_patterns.should include(".git")
      @project.ignore_patterns.should include(".svn")
    end

  end

  describe "#ignore" do

    it "adds to ignore_patterns" do
      @project.ignore("foo")
      @project.ignore_patterns
    end

  end

end
