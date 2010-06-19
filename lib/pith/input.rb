require "tilt"
require "pith/output_context"
require "pith/metadata"

module Pith
  
  class Input
    
    def initialize(project, path)
      @project = project
      @path = path
    end

    attr_reader :project, :path
    
    def build
      ignore || evaluate_as_tilt_template || copy_verbatim
    end

    def relative_input(name)
      resolved_path = relative_path(name)
      input = project.inputs.find do |input|
        input.path == resolved_path
      end
      raise %{can't locate "#{resolved_path}"} if input.nil?
      input
    end
    
    def relative_path(name)
      name = name.to_str
      if name[0,1] == "/"
        Pathname(name[1..-1])
      else
        path.parent + name
      end
    end
    
    def render(context, locals = {}, &block)
      Tilt.new(full_path).render(context, locals, &block)
    end

    def meta
      if @metadata.nil?
        full_path.open do |io|
          @metadata = Pith::Metadata.extract_from(io).freeze
        end
      end
      @metadata
    end
    
    private

    def logger
      project.logger
    end

    def trace(strategy, output_path = nil)
      output_path ||= "X"
      logger.info("%-36s%-14s%s" % [path, "--(#{strategy})-->", output_path])
    end
    
    def full_path
      project.input_dir + path
    end
    
    def ignore
      path.to_s.split("/").any? { |component| component.to_s[0,1] == "_" }
    end
    alias :ignorable? :ignore
    
    def evaluate_as_tilt_template
      if path.to_s =~ /^(.*)\.(.*)$/ && Tilt.registered?($2)
        output_path = Pathname($1); ext = $2
        trace(ext, output_path)
        output_file = project.output_dir + output_path
        output_file.parent.mkpath
        output_file.open("w") do |out|
          output = render(OutputContext.new(self))
          out.puts(output)
        end
        output_file
      end
    end

    def copy_verbatim
      trace("copy", path)
      output_path = project.output_dir + path
      output_path.parent.mkpath
      FileUtils.copy(full_path, output_path)
      output_path
    end

  end
  
end
