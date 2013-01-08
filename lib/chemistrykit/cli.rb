require "thor"
require 'chemistrykit/generators'
require 'chemistrykit/new'
require 'rspec'

module ChemistryKit
  module CLI
    class CKitCLI < Thor

      default_task :brew

      register(ChemistryKit::CLI::Generate, 'generate', 'generate [GENERATOR] [NAME]', 'generates something')
      register(ChemistryKit::CLI::New, 'new', 'new [NAME]', 'Creates a new ChemistryKit project')

      desc "brew", "Run the Chemistry kit"
      long_desc <<-LONGDESC
        Runs the Chemistry kit
      LONGDESC
      option :tag, :default => 'depth:shallow', :type => :array
      def brew
        require 'chemistrykit/config'
        require "#{Dir.getwd}/spec/helpers/spec_helper"
        
        tags = {}
        options['tag'].each do |tag|
          filter_type = tag.start_with?('~') ? :exclusion_filter : :filter

          name, value = tag.gsub(/^(~@|~|@)/, '').split(':')
          name = name.to_sym

          value = true if value.nil?

          tags[filter_type] ||= {}
          tags[filter_type][name] = value
        end

        RSpec.configure do |c|
          c.filter_run tags[:filter] unless tags[:filter].nil?
          c.filter_run_excluding tags[:exclusion_filter] unless tags[:exclusion_filter].nil?
        end
        RSpec::Core::Runner.run(Dir.glob(File.join(Dir.getwd, 'spec', '**/*_spec.rb')))
      end
    end
  end
end
