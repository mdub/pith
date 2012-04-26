require 'spec_helper'
require 'pith/pathname_ext'

describe Pathname do

  let(:pathname) { Pathname("foo/bar") }

  describe "#in?" do

    it "returns false for siblings" do
      pathname.in?("foo/baz").should == false
    end

    it "returns true for ancestors" do
      pathname.in?("foo").should == true
    end

    it "returns false for other prefixes" do
      pathname.in?("fo").should == false
      pathname.in?("foo/b").should == false
    end

    it "returns false for itself" do
      pathname.in?("foo/bar").should == false
    end

  end

end
