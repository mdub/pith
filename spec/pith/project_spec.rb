require 'spec_helper'
require 'pith/project'

describe Pith::Project do

  before do
    $input_dir.mkpath
    @project = Pith::Project.new(:input_dir => $input_dir)
  end

  describe "#input" do

    describe "(with a template input path)" do

      before do
        @input_file = $input_dir + "input.html.haml"
        @input_file.touch
      end

      it "constructs an Input object" do
        @input = @project.input("input.html.haml")
        @input.should be_kind_of(Pith::Input)
        @input.file.should == @input_file
      end

    end

    describe "(with a template output path)" do

      before do
        @input_file = $input_dir + "input.html.haml"
        @input_file.touch
      end

      it "can also be used to locate the Input" do
        @project.input("input.html").should == @project.input("input.html.haml")
      end

    end

    describe "(with an invalid input path)" do

      it "returns nil" do
        @project.input("bogus.path").should be_nil
      end

    end

  end

  describe "when an input file is unchanged" do

    before do
      @input_file = $input_dir + "input.html.haml"
      @input_file.touch
    end

    describe "a second call to #input" do
      it "returns the same Input object" do

        first_time = @project.input("input.html.haml")
        first_time.should_not be_nil

        @project.refresh
        second_time = @project.input("input.html.haml")
        second_time.should equal(first_time)

      end
    end

  end

  describe "when an input file is changed" do

    before do
      @input_file = $input_dir + "input.html.haml"
      @input_file.touch(Time.now - 10)
    end

    describe "a second call to #input" do
      it "returns a different Input object" do

        first_time = @project.input("input.html.haml")
        first_time.should_not be_nil

        @input_file.touch(Time.now)

        @project.refresh
        second_time = @project.input("input.html.haml")
        second_time.should_not be_nil
        second_time.should_not equal(first_time)

      end
    end

  end

  describe "when an input file is removed" do

    before do
      @input_file = $input_dir + "input.html.haml"
      @input_file.touch(Time.now - 10)
    end

    describe "a second call to #input" do
      it "returns nil" do

        first_time = @project.input("input.html.haml")
        first_time.should_not be_nil

        FileUtils.rm(@input_file)

        @project.refresh
        second_time = @project.input("input.html.haml")
        second_time.should be_nil

      end
    end

  end

end
