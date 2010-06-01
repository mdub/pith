require 'spec_helper'
require 'pith'

describe "pith build" do

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
    end
    
  end
  
end
