require 'spec_helper'
require "pith/input"
require "pith/project"

describe Pith::Input do

  before do
    @project = Pith::Project.new($input_dir)
  end

  def make_input(path)
    path = Pathname(path)
    input_file = $input_dir + path
    input_file.parent.mkpath
    input_file.open("w") do |io|
      yield io if block_given?
    end
    Pith::Input.new(@project, path)
  end

  context "for a template" do

    subject do
      make_input("dir/some_page.html.md.erb")
    end

    it { is_expected.to be_template }

    describe "#title" do

      it "is based on last component of filename" do
        expect(subject.title).to eq("Some page")
      end

      it "can be over-ridden in metadata" do
        input = make_input("dir/some_page.html.haml") do |i|
          i.puts "---"
          i.puts "title: Blah blah"
          i.puts "..."
        end
        expect(input.title).to eq("Blah blah")
      end

    end

    describe "#output" do

      it "returns an Output" do
        expect(subject.output).not_to be_nil
      end

    end

    describe "#output_path" do

      it "excludes the template-type extensions" do
        expect(subject.output_path).to eq(Pathname("dir/some_page.html"))
      end

    end

    describe "#pipeline" do

      it "is a list of Tilt processors" do
        expect(subject.pipeline).to eq([Tilt["erb"], Tilt["md"]])
      end

    end

  end

  context "for a resource" do

    subject do
      make_input("dir/some_image.gif")
    end

    it { is_expected.not_to be_template }

    describe "pipeline" do
      it "should be empty" do
        expect(subject.pipeline).to be_empty
      end
    end

  end

  context "for an ignored file" do

    subject do
      make_input("_blah/blah.de")
    end

    describe "output" do
      it "should be nil" do
        expect(subject.output).to be_nil
      end
    end

  end

end
