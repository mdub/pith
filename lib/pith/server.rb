require "rack"
require "pathname"

module Pith

  module Server

    def new(project)
      Rack::Builder.new do
        use Rack::CommonLogger
        use Rack::ShowExceptions
        use Rack::Lint
        use Pith::Server::OutputFinder, project
        run Rack::Directory.new(project.output_dir)
      end
    end

    extend self

    class OutputFinder

      def initialize(app, project)
        @app  = app
        @project = project
      end

      def call(env)

        path_info = ::Rack::Utils.unescape(env["PATH_INFO"])

        output_map = {}
        @project.outputs.each do |output|
          output_map["/#{output.path}"] = output
        end

        ["", ".html", "index.html"].each do |ext|
          output = output_map[path_info + ext]
          if output
            env["PATH_INFO"] += ext
            output.build
            break
          end
        end

        # file = "#{@root}#{path_info}"
        # unless File.exist?(file)
        #   if File.exist?("#{file}.html")
        #     env["PATH_INFO"] += ".html"
        #   end
        # end

        @app.call(env)

      end

    end

  end

end
