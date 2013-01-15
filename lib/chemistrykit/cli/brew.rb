require 'rspec' # TODO: Make sure this is correct when rspec configs are refactored
require 'chemistrykit/config'
require 'chemistrykit/shared_context'
require "#{Dir.getwd}/spec/helpers/spec_helper"

module ChemistryKit
  module CLI
    class Brew < Thor

      # TODO: Pass tags from thor to filter_run_excluding
      # TODO: Refactor Rspec configs our of cli
      # TODO: Need to decide what the names of scripts will be and where they live
      # TODO: Destory all of the comments!!

      # TODO: Rspec setup should be moved outside of the cmd line files
      # Good intro to Rspec way here: http://blog.davidchelimsky.net/2010/06/14/filtering-examples-in-rspec-2/
      RSpec.configure do |t|
        t.spec_opts = ['--options', "./.rspec"]
        # If you pass me a tag, then run that one
        t.filter_run tags[:filter] unless tags[:filter].nil?
        # If you exclude a tag, don't run it
        t.filter_run_excluding tags[:exclusion_filter] unless tags[:exclusion_filter].nil?
        # This should set a default tag. See RSpec::Core::Configuration docs for usage
        t.filter_run_including :depth => 'shallow'
        # Use Project level configs
        t.include ChemistryKit::SharedContext
        # Make it all random!
        t.order = 'random'
        t.spec_files = FileList['spec/**/*_spec.rb']
      end


      #def log_timestamp
      #  Time.now.strftime("%Y-%m-%d-%H-%M-%S")
      #end

      #def exit_code
      #  RSpec::Core::Runner.run(Dir.glob(File.join(Dir.getwd, 'spec', '**/*_spec.rb')))
      #end

      #FileUtils.makedirs(File.join(Dir.getwd, 'logs', log_timestamp))

      #ENV['CI_REPORTS'] = File.join(Dir.getwd, 'logs', log_timestamp)
      #ENV['CI_CAPTURE'] = CHEMISTRY_CONFIG['chemistrykit']['capture_output'] ? 'on' : 'off'



      # if RUBY_PLATFORM.downcase.include?("mswin")
      #   require 'win32/dir'

      #   if Dir.junction?(File.join(Dir.getwd, 'logs', 'latest'))
      #     File.delete(File.join(Dir.getwd, 'logs', 'latest'))
      #   end
      #   Dir.create_junction(File.join(Dir.getwd, 'logs', 'latest'), File.join(Dir.getwd, 'logs', log_timestamp))
      # else
      #   if File.symlink?(File.join(Dir.getwd, 'logs', 'latest'))
      #     File.delete(File.join(Dir.getwd, 'logs', 'latest'))
      #   end
      #   File.symlink(File.join(Dir.getwd, 'logs', log_timestamp), File.join(Dir.getwd, 'logs', 'latest'))
      # end
      # exit_code
    end
  end
end
