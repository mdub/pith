require "tilt"

module Pith
  
  class Item
    
    def initialize(project, input_file)
      @project = project
      @input_file = input_file
      @relative_path = input_file.relative_path_from(project.input_dir)
    end

    attr_accessor :project, :input_file, :relative_path, :extension
    
    def build
      evaluate_as_tilt_template || copy_verbatim
    end
    
    def evaluate_as_tilt_template
      if relative_path.to_s =~ /^(.*)\.(.*)$/ && Tilt.registered?($2)
        output_file = project.output_dir + $1
        template = Tilt.new(input_file)
        output = template.render
        output_file.parent.mkpath
        output_file.open("w") do |out|
          out.puts(output)
        end
        output_file
      end
    end

    def copy_verbatim
      output_file = project.output_dir + relative_path
      FileUtils.copy(input_file, output_file)
      output_file
    end

  end
  
end
