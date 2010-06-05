require "tilt"
require "pith/output_context"

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

    def resolve(name)
      resolved_path = path.parent + name
      project.inputs.find do |input|
        input.path == resolved_path
      end
    end
    
    def render(context, locals = {}, &block)
      Tilt.new(full_path).render(context, locals, &block)
    end

    private

    def full_path
      project.input_dir + path
    end
    
    def ignore
      path.to_s.split("/").any? { |component| component.to_s[0,1] == "_" }
    end
    alias :ignorable? :ignore
    
    def evaluate_as_tilt_template
      if path.to_s =~ /^(.*)\.(.*)$/ && Tilt.registered?($2)
        output_file = project.output_dir + $1
        output_file.parent.mkpath
        output_file.open("w") do |out|
          output = render(OutputContext.new(self))
          out.puts(output)
        end
        output_file
      end
    end

    def copy_verbatim
      output_path = project.output_dir + path
      output_path.parent.mkpath
      FileUtils.copy(full_path, output_path)
      output_path
    end

  end
  
end
