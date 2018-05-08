require 'spec_helper'
require 'pith/config'

describe Pith::Config do

  let(:config) { Pith::Config.new }

  describe "#ignore_patterns" do

    it "is a set" do
      expect(config.ignore_patterns).to be_kind_of(Set)
    end

    it "includes some sensible defaults" do
      expect(config.ignore_patterns).to include("_*")
      expect(config.ignore_patterns).to include(".git")
      expect(config.ignore_patterns).to include(".svn")
    end

  end

  describe "#ignore" do

    it "adds to ignore_patterns" do
      config.ignore("foo")
      expect(config.ignore_patterns).to be_member('foo')
    end

    it "adds multiple patterns to ignore_patterns (when passed multiple arguments)" do
      config.ignore("foo", "bar")
      expect(config.ignore_patterns).to be_member('foo')
      expect(config.ignore_patterns).to be_member('bar')
    end

    it "adds multiple patterns to ignore_patterns (when passed an array)" do
      config.ignore(["foo", "bar"])
      expect(config.ignore_patterns).to be_member('foo')
      expect(config.ignore_patterns).to be_member('bar')
    end

  end

end
