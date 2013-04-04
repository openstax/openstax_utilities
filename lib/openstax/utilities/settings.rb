
module OpenStax
  module Utilities
    module Settings

      # Reads and returns a hash of YAML settings from a file
      # @param calling_file This should always be __FILE__
      # @param relative_directory This is a relative directory path that denotes 
      # the move from the directory containing calling_file, e.g. ".." will cause 
      # this method to look up one directory from the directory of calling_file
      # @param filename the plain filename, e.g. 'foobar.yml'
      #
      def self.load_settings(calling_file, relative_directory, filename)
        settings = {}
        
        filename = File.join(File.dirname(calling_file), '..', 'developer_settings.yml')
        
        if File.file?(filename)
          settings = YAML::load_file(filename)
          settings.symbolize_keys!
        end

        settings
      end

    end
  end
end