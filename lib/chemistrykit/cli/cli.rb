require "thor"
require 'chemistrykit/cli/generators'
require 'chemistrykit/cli/new'
require 'rspec'

module ChemistryKit
  module CLI
    class CKitCLI < Thor
      check_unknown_options!

      default_task :help

      register(ChemistryKit::CLI::Generate, 'generate', 'generate <object> or <beaker> [NAME]', 'generates a page object or script')
      register(ChemistryKit::CLI::New, 'new', 'new [NAME]', 'Creates a new ChemistryKit project')

      desc "brew", "Run the Chemistry kit"
      long_desc <<-LONGDESC
        Runs the Chemistry kit
      LONGDESC
      method_option :tag, :default => ['depth:shallow'], :type => :array
      def brew
        require 'chemistrykit/config'
        require 'chemistrykit/shared_context'
        #require "#{Dir.getwd}/spec/helpers/spec_helper"
        require 'ci/reporter/rake/rspec_loader'

        tags = {}
        options['tag'].each do |tag|
          filter_type = tag.start_with?('~') ? :exclusion_filter : :filter

          name, value = tag.gsub(/^(~@|~|@)/, '').split(':')
          name = name.to_sym

          value = true if value.nil?

          tags[filter_type] ||= {}
          tags[filter_type][name] = value
        end

        log_timestamp = Time.now.strftime("%Y-%m-%d-%H-%M-%S")
        FileUtils.makedirs(File.join(Dir.getwd, 'logs', log_timestamp))

        ENV['CI_REPORTS'] = File.join(Dir.getwd, 'logs', log_timestamp)
        ENV['CI_CAPTURE'] = CHEMISTRY_CONFIG['chemistrykit']['capture_output'] ? 'on' : 'off'

        RSpec.configure do |c|
          c.filter_run tags[:filter] unless tags[:filter].nil?
          c.filter_run_excluding tags[:exclusion_filter] unless tags[:exclusion_filter].nil?
          c.include ChemistryKit::SharedContext
          c.order = 'random'
        end

        exit_code = RSpec::Core::Runner.run(Dir.glob(File.join(Dir.getwd, 'scripts', '**/*_beaker.rb')))

        if RUBY_PLATFORM.downcase.include?("mswin")
          require 'win32/dir'

          if Dir.junction?(File.join(Dir.getwd, 'logs', 'latest'))
            File.delete(File.join(Dir.getwd, 'logs', 'latest'))
          end
          Dir.create_junction(File.join(Dir.getwd, 'logs', 'latest'), File.join(Dir.getwd, 'logs', log_timestamp))
        else
          if File.symlink?(File.join(Dir.getwd, 'logs', 'latest'))
            File.delete(File.join(Dir.getwd, 'logs', 'latest'))
          end
          File.symlink(File.join(Dir.getwd, 'logs', log_timestamp), File.join(Dir.getwd, 'logs', 'latest'))
        end
        exit_code
      end
    end
  end
end
