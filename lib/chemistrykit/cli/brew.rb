require 'chemistrykit/config'
require 'chemistrykit/shared_context'
require "#{Dir.getwd}/spec/helpers/spec_helper"
require 'thor/rake_compat'
require 'ci/reporter/rake/rspec'
require 'rspec/core/rake_task'

module ChemistryKit
  module CLI
    class Brew < Thor
      include Thor::RakeCompat

      option :tag, :default => ['depth:shallow'], :type => :array

      # TODO: Pass tags from thor to filter_run_excluding

      # TODO: We probably don't need to use rake here. Instead, perhaps call something like Rspec.configure
      RSpec::Core::RakeTask.new(:spec) do |t|
        t.spec_opts = ['--options', "./.rspec"]
        t.filter_run tags[:filter] unless tags[:filter].nil?
        t.filter_run_excluding tags[:exclusion_filter] unless tags[:exclusion_filter].nil?
        t.include ChemistryKit::SharedContext
        t.order = 'random'
        # TODO: Need to decide what the names of scripts will be and where they live
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
