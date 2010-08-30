require "yaml"

module Pith
  
  module Metadata
    
    extend self
    
    def extract_from(io)
      line = io.gets
      return nil unless line =~ /---$/
      metadata_prefix = $`
      yaml = ""
      while line && line.start_with?(metadata_prefix)
        yaml << line[metadata_prefix.size .. -1]
        line = io.gets
      end
      begin
        YAML.load(yaml)
      rescue 
        nil
      end
    end
  
  end
  
end
