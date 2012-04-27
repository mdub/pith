require "rack"
require "pathname"
require "thread"

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

        @project.sync_every(1)

        path_info = ::Rack::Utils.unescape(env["PATH_INFO"])
        ends_with_slash = (path_info[-1] == '/')

        outputs = @project.outputs.sort_by { |output| output.path }
        outputs.each do |output|

          output_path = "/" + output.path.to_s

          if !ends_with_slash && output_path =~ %r{^#{path_info}/}
            return [
              302,
              { "Location" => path_info + "/" },
              []
            ]
          end

          ["", ".html", "index.html"].map do |ext|
            if output_path == (path_info + ext)
              output.build
              env["PATH_INFO"] += ext
              return @app.call(env)
            end
          end

        end

        @app.call(env)

      end

    end

  end

end
