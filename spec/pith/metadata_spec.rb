require 'spec_helper'
require 'stringio'

require 'pith/metadata'

describe Pith::Metadata do

  def metadata
    Pith::Metadata.extract_from(StringIO.new(@input))
  end
  
  describe "when input contains no YAML metadata" do
    
    before do
      @input = "%p Blah blah"
    end
    
    it "returns nil" do
      metadata.should == nil
    end
    
  end

  describe "when input contains YAML metadata" do
    
    before do
      @input = <<-HAML.gsub(/^ +/, '')
      -# ---
      -# x: 1
      -# y: "2"
      -# ...
      -# other stuff
      HAML
    end
    
    it "extracts the metadata" do
      metadata.should == {
        "x" => 1,
        "y" => "2"
      }
    end
    
  end

  describe "when input contains badly-formed YAML" do
    
    before do
      @input = <<-HAML.gsub(/^ +/, '')
      -# ---
      -# title: "No quotes", she said 
      -# ...
      -# other stuff
      HAML
    end
    
    it "returns nil" do
      metadata.should == nil
    end
    
  end

end

