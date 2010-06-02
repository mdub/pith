require 'spec_helper'
require 'pith'
require 'nokogiri'

describe Pith::Project do

  before :all do
    $tmp_dir.mkpath
    @output_dir = $tmp_dir + "output"
    @output_dir.rmtree if @output_dir.exist?
    @project = Pith::Project.new(:input_dir => $sample_input_dir, :output_dir => @output_dir)
  end

  describe "#build" do

    before :all do
      @project.build
    end

    it "converts HAML files to HTML" do
      index_html_file = @output_dir + "index.html"
      index_html_file.should exist
      html_doc = Nokogiri::HTML.parse(index_html_file.open)
      html_doc.search("//h1").first.text.should == "Sample index"
    end

    it "copies other files across, intact" do
      @input_file = @project.input_dir + "verbatim.txt"
      @output_file = @project.output_dir + "verbatim.txt"
      @output_file.should exist
      @output_file.read.should == @input_file.read
    end
    
  end
  
end
