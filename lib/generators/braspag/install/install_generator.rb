module Braspag
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      desc "Copy braspag.yml file to your application config directory."

      def self.source_root
        @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      end

      def copy_config_file
        template "config/braspag.yml"
      end
    end
  end
end