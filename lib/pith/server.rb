require "rack"
require "adsf/rack"

module Pith

  module Server

    def new(project)
      Rack::Builder.new do
        use Rack::CommonLogger, project.logger
        use Rack::ShowExceptions
        use Rack::Lint
        use Pith::Server::AutoBuild, project
        use Adsf::Rack::IndexFileFinder, :root => project.output_dir
        use Pith::Server::DefaultToHtml, project.output_dir
        run Rack::Directory.new(project.output_dir)
      end
    end

    def run(project, options = {})
      Rack::Handler.get("thin").run(new(project), options)
    end

    extend self

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

    class DefaultToHtml

      def initialize(app, root)
        @app  = app
        @root = root
      end

      def call(env)

        path_info = ::Rack::Utils.unescape(env["PATH_INFO"])
        file = "#{@root}#{path_info}"
        unless File.exist?(file)
          if File.exist?("#{file}.html")
            env["PATH_INFO"] += ".html"
          end
        end

        @app.call(env)

      end

    end

  end

end
