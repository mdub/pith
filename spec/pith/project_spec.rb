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
      expect($output_dir).to be_directory
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
        expect(@input).to be_kind_of(Pith::Input)
        expect(@input.file).to eq(@input_file)
      end

      it "returns the same object the second time" do
        first_time = @project.input("input.html.haml")
        second_time = @project.input("input.html.haml")
        expect(second_time).to equal(first_time)
      end

    end

    describe "(with an invalid input path)" do

      it "returns nil" do
        expect(@project.input("bogus.path")).to be_nil
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
        expect(output).to be_kind_of(Pith::Output)
        expect(output.file).to eq($output_dir + "input.html")
      end

    end

    describe "(with a bogus output path)" do

      let(:output) { @project.output("bogus.html.haml") }

      it "returns nil" do
        expect(output).to be_nil
      end

    end

  end

  describe "when an input file is removed" do

    before do
      @input_file = $input_dir + "input.html.haml"
      @input_file.touch(Time.now - 10)
      @project.sync
      expect(@project.input("input.html.haml")).not_to be_nil
      expect(@project.output("input.html")).not_to be_nil
      FileUtils.rm(@input_file)
      @project.sync
    end

    describe "#input" do
      it "returns nil" do
        expect(@project.input("input.html.haml")).to be_nil
      end
    end

    describe "#output" do
      it "returns nil" do
        expect(@project.output("input.html")).to be_nil
      end
    end

    it "doesn't confuse subsequent calls to #sync" do
      expect { @project.sync }.not_to raise_error
    end

  end

end
