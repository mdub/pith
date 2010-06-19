require "yaml"

module Pith
  
  module Metadata
    
    extend self
    
    def extract_from(io)
      line = io.gets
      if line =~ /---$/
        metadata_prefix = $`
        yaml = ""
        while line && line.start_with?(metadata_prefix)
          yaml << line[metadata_prefix.size .. -1]
          line = io.gets
        end
        YAML.load(yaml)
      else
        Hash.new
      end
    end
  
  end
  
end
