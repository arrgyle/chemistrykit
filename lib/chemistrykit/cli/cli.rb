require "thor"
require 'rspec'
require 'chemistrykit/cli/generators'
require 'chemistrykit/cli/new'

module ChemistryKit
  module CLI
    class CKitCLI < Thor

      register(ChemistryKit::CLI::Generate, 'generate', 'generate [GENERATOR] [NAME]', 'generates something')
      register(ChemistryKit::CLI::New, 'new', 'new [NAME]', 'Creates a new ChemistryKit project')

      # TODO: Pass tags from thor to filter_run_excluding in rspec_config
      # TODO: Need to decide what the names of scripts will be and where they live
      # TODO: Destory all of the comments!!


      # TODO: Accept and pass a tag to rspec_config
      desc 'brew', 'Run ChemistryKit'
      def brew
        # TODO: Pull out these requires from the method
        require 'chemistrykit/config' # This is requiring a a file that's available in userland. How to make that more clear?
        require 'chemistrykit/shared_context'
        require "#{Dir.getwd}/spec/helpers/spec_helper"

        def log_timestamp
          Time.now.strftime("%Y-%m-%d-%H-%M-%S")
        end

        def exit_code
          RSpec::Core::Runner.run(Dir.glob(File.join(Dir.getwd, 'spec', '**/*_spec.rb')))
        end

        FileUtils.makedirs(File.join(Dir.getwd, 'logs', log_timestamp))

        ENV['CI_REPORTS'] = File.join(Dir.getwd, 'logs', log_timestamp)
        ENV['CI_CAPTURE'] = CHEMISTRY_CONFIG['chemistrykit']['capture_output'] ? 'on' : 'off'

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
