require "rack"
require "adsf/rack"
require "logger"

module Pith

  module Server

    class << self

      def new(project)
        Rack::Builder.new do
          use Rack::CommonLogger, project.logger
          use Rack::ShowExceptions
          use Rack::Lint
          use Pith::Server::AutoBuild, project
          use Adsf::Rack::IndexFileFinder, :root => project.output_dir
          run Rack::File.new(project.output_dir)
        end
      end

      def run(project)
        app = new(project)
        Rack::Handler.get("thin").run(app, :Port => 4321)
      end

    end

    class AutoBuild

      def initialize(app, project)
        @app = app
        @project = project
      end

      def call(env)
        @project.build
        @app.call(env)
      end

    end

  end

end
