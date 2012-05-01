require 'spec_helper'
require 'pith/config'

describe Pith::Config do

  let(:config) { Pith::Config.new }

  describe "#ignore_patterns" do

    it "is a set" do
      config.ignore_patterns.should be_kind_of(Set)
    end

    it "includes some sensible defaults" do
      config.ignore_patterns.should include("_*")
      config.ignore_patterns.should include(".git")
      config.ignore_patterns.should include(".svn")
    end

  end

  describe "#ignore" do

    it "adds to ignore_patterns" do
      config.ignore("foo")
      config.ignore_patterns
    end

  end

end
