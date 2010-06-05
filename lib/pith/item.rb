require "tilt"

module Pith
  
  class Item
    
    def initialize(project, input_file)
      @project = project
      @input_file = input_file
    end

    attr_reader :project, :input_file

    def relative_path
      @relative_path ||= input_file.relative_path_from(project.input_dir)
    end
    
    def build
      ignore || evaluate_as_tilt_template || copy_verbatim
    end
    
    private

    def ignore
      relative_path.basename.to_s[0,1] == "_"
    end
    
    def evaluate_as_tilt_template
      if relative_path.to_s =~ /^(.*)\.(.*)$/ && Tilt.registered?($2)
        output_file = project.output_dir + $1
        output_file.parent.mkpath
        output_file.open("w") do |out|
          output = project.render(relative_path, ItemContext.new(self))
          out.puts(output)
        end
        output_file
      end
    end

    def copy_verbatim
      output_file = project.output_dir + relative_path
      output_file.parent.mkpath
      FileUtils.copy(input_file, output_file)
      output_file
    end

  end
  
  class ItemContext
    
    include Tilt::CompileSite
    
    def initialize(item)
      @item = item
    end
    
    attr_reader :item
    
    def include(name, locals = {}, &block)
      content_block = if block_given?
        content = capture_haml(&block)
        proc { content }
      end
      item.project.render(name, self, locals, &content_block)
    end
    
  end
  
end
