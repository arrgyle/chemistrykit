require 'thor/group'

module ChemistryKit
  module CLI
    class New < Thor::Group
      include Thor::Actions

      argument :name, optional: true

      def self.source_root
        File.join(File.dirname(__FILE__), '..', '..')
      end

      def create_project
        directory "templates/chemistrykit", project_path
      end

      def notify
        say "Your project name has been added to _config/chemistrykit.yaml"
      end

    private

      def project_path
        if named?
          File.join(Dir.getwd, name_or_directory_name)
        else
          Dir.getwd
        end
      end

      def name_or_directory_name
        named? ? name : File.basename(Dir.getwd)
      end

      def named?
        !name.nil? && name != '.'
      end

    end
  end
end
