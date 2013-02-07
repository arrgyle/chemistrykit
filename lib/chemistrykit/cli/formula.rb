require 'thor/group'

module ChemistryKit
  module CLI
    class PageObjectGenerator < Thor::Group
      include Thor::Actions

      argument :name

      def self.source_root
        File.join(File.dirname(File.expand_path(__FILE__)), '../../templates/')
      end

      def copy_file
        template "formula.tt", "./formulas/#{name}.rb"
        template "beaker_with_formula.tt", "./beakers/#{name}_beaker.rb"
      end

    end
  end
end
