require 'spec_helper'
require 'pith/server'
require 'rack/mock'

describe Pith::Server::OutputFinder do

  let(:output_path) { "output" }
  let(:output) { stub(:path => Pathname(output_path), :build => true) }

  let(:project) do
    stub(:outputs => [output])
  end

  let(:app) do
    lambda do |env|
      [
        200,
        { "Location" => env["PATH_INFO"] },
        ["OKAY"]
      ]
    end
  end

  let(:middleware) do
    Pith::Server::OutputFinder.new(app, project)
  end

  let(:request_uri) { "/foo" }
  let(:request_env) do
    Rack::MockRequest.env_for(request_uri)
  end

  let(:result) do
    middleware.call(request_env)
  end

  let(:result_path) do
    status, headers, body = *result
    headers["Location"]
  end

  context "when no matching file exists" do

    let(:request_uri) { "/foo" }

    it "does not build the output" do
      output.should_not_receive(:build)
      result_path
    end

    it "passes on the env unchanged" do
      result_path.should == "/foo"
    end

  end

  context "when an exact match exists" do

    let(:output_path) { "foo.html" }
    let(:request_uri) { "/foo.html" }

    it "builds the output" do
      output.should_receive(:build)
      result_path
    end

    it "passes on the env unchanged" do
      result_path.should == "/foo.html"
    end

  end

  context "when a matching .html output exists" do

    let(:output_path) { "foo.html" }
    let(:request_uri) { "/foo" }

    it "builds the output" do
      output.should_receive(:build)
      result_path
    end

    it "modifies PATH_INFO" do
      result_path.should == "/foo.html"
    end

  end

  context "when a matching index.html output exists" do

    let(:output_path) { "foo/index.html" }
    let(:request_uri) { "/foo/" }

    it "builds the output" do
      output.should_receive(:build)
      result_path
    end

    it "modifies PATH_INFO" do
      result_path.should == "/foo/index.html"
    end

  end

end

