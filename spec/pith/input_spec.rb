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

    it { should be_template }

    describe "#title" do

      it "is based on last component of filename" do
        subject.title.should == "Some page"
      end

      it "can be over-ridden in metadata" do
        input = make_input("dir/some_page.html.haml") do |i|
          i.puts "---"
          i.puts "title: Blah blah"
          i.puts "..."
        end
        input.title.should == "Blah blah"
      end

    end

    describe "#output" do

      it "returns an Output" do
        subject.output.should_not be_nil
      end

    end

    describe "#output_path" do

      it "excludes the template-type extensions" do
        subject.output_path.should == Pathname("dir/some_page.html")
      end

    end

    describe "#pipeline" do

      it "is a list of Tilt processors" do
        subject.pipeline.should == [Tilt["erb"], Tilt["md"]]
      end

    end

  end

  context "for a resource" do

    subject do
      make_input("dir/some_image.gif")
    end

    it { should_not be_template }

    its(:pipeline) { should be_empty }

  end

  context "for an ignored file" do

    subject do
      make_input("_blah/blah.de")
    end

    its(:output) { should be_nil }

  end

end
