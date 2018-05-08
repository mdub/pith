require 'spec_helper'
require 'pith/server'
require 'rack/mock'

describe Pith::Server::OutputFinder do

  let(:output_path) { "dir/index.html" }
  let(:output) { double(:path => Pathname(output_path), :build => true) }

  let(:project) do
    double(:outputs => [output])
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

  let(:result_status) do
    result[0]
  end

  let(:result_headers) do
    result[1]
  end

  let(:result_path) do
    result_headers["Location"]
  end

  context "request for a non-existant file" do

    let(:request_uri) { "/bogus.html" }

    it "does not build the output" do
      output.should_not_receive(:build)
      result_path
    end

    it "passes on the env unchanged" do
      result_path.should == "/bogus.html"
    end

  end

  def self.can_request_output(description, uri)

    context "request for output #{description}" do

      let(:request_uri) { uri }

      it "builds the output" do
        output.should_receive(:build)
        result_path
      end

      it "passes on request" do
        result_path.should == "/dir/index.html"
      end

    end

  end

  can_request_output "directly", "/dir/index.html"

  can_request_output "without .html", "/dir/index"

  can_request_output "directory with slash", "/dir/"

  context "request for directory without slash" do

    let(:request_uri) { "/dir" }

    it "redirects" do
      result_status.should == 302
      result_headers["Location"].should == "/dir/"
    end

  end

end
