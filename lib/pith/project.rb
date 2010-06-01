require "pathname"
require "tilt"
require "logger"

module Pith
  class Project
    
    def initialize(attributes = {})
      attributes.each do |k,v|
        send("#{k}=", v)
      end
    end
    
    attr_accessor :input_dir, :output_dir
    
    def build
      Pathname.glob(input_dir + "**/*").each do |input_file|
        build_item(input_file)
      end
    end

    def logger
      @logger ||= Logger.new(nil)
    end
    
    private
    
    def build_item(input_file)
      output_file = output_dir + input_file.relative_path_from(input_dir)
      if output_file.to_s =~ /^(.*)\.(.*)$/ && Tilt.registered?($2)
        output_file = Pathname($1)
        logger.info "--> #{output_file}"
        template = Tilt.new(input_file)
        output = template.render
        output_file.parent.mkpath
        output_file.open("w") do |out|
          out.puts(output)
        end
      else
        FileUtils.copy(input_file, output_file)
      end
    end
    
  end
end
