require 'chemistrykit/config'
require 'chemistrykit/shared_context'
require "#{Dir.getwd}/spec/helpers/spec_helper"
require 'ci/reporter/rake/rspec_loader'

module ChemistryKit
  module CLI
    class Brew < Thor

      desc "brew", "Runs the scripts in Chemistrykit"
      argument :tag, :default => ['depth:shallow'], :type => :array

      #  tags = {}
      #  options['tag'].each do |tag|
      #    filter_type = tag.start_with?('~') ? :exclusion_filter : :filter

      #    name, value = tag.gsub(/^(~@|~|@)/, '').split(':')
      #    name = name.to_sym

      #    value = true if value.nil?

      #    tags[filter_type] ||= {}
      #    tags[filter_type][name] = value
      #  end

      #def log_timestamp
      #  Time.now.strftime("%Y-%m-%d-%H-%M-%S")
      #end

      #def exit_code
      #  RSpec::Core::Runner.run(Dir.glob(File.join(Dir.getwd, 'spec', '**/*_spec.rb')))
      #end

      #FileUtils.makedirs(File.join(Dir.getwd, 'logs', log_timestamp))

      #ENV['CI_REPORTS'] = File.join(Dir.getwd, 'logs', log_timestamp)
      #ENV['CI_CAPTURE'] = CHEMISTRY_CONFIG['chemistrykit']['capture_output'] ? 'on' : 'off'

      # RSpec.configure do |c|
      #   c.filter_run tags[:filter] unless tags[:filter].nil?
      #   c.filter_run_excluding tags[:exclusion_filter] unless tags[:exclusion_filter].nil?
      #   c.include ChemistryKit::SharedContext
      #   c.order = 'random'
      # end


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
