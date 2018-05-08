require 'spec_helper'
require 'pith/pathname_ext'

describe Pathname do

  let(:pathname) { Pathname("foo/bar") }

  describe "#in?" do

    it "returns false for siblings" do
      expect(pathname.in?("foo/baz")).to eq(false)
    end

    it "returns true for ancestors" do
      expect(pathname.in?("foo")).to eq(true)
    end

    it "returns false for other prefixes" do
      expect(pathname.in?("fo")).to eq(false)
      expect(pathname.in?("foo/b")).to eq(false)
    end

    it "returns false for itself" do
      expect(pathname.in?("foo/bar")).to eq(false)
    end

  end

end
