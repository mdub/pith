require 'spec_helper'
require 'stringio'

require 'pith/metadata'

describe Pith::Metadata do

  def metadata
    Pith::Metadata.extract_from(StringIO.new(@input))
  end
  
  describe "with input containing no YAML metadata" do
    
    before do
      @input = "%p Blah blah"
    end
    
    it "returns an empty Hash" do
      metadata.should == {}
    end
    
  end

  describe "with input containing YAML metadata" do
    
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

end

