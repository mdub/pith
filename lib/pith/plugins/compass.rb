require "compass"
require "tilt/css"

module Pith
  module Compass

    module Initialize

      def initialize(file=nil, line=1, options={}, &block)
        options = options.merge(::Compass.sass_engine_options)
        super(file, line, options, &block)
      end

    end

    class SassTemplate < Tilt::SassTemplate
      include Initialize
    end

    class ScssTemplate < Tilt::ScssTemplate
      include Initialize
    end

  end
end

Tilt.register Pith::Compass::SassTemplate, 'sass'
Tilt.register Pith::Compass::ScssTemplate, 'scss'
