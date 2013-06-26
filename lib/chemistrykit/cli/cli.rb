require 'thor'
require 'rspec'
require 'ci/reporter/rake/rspec_loader'
require 'chemistrykit/cli/new'
require 'chemistrykit/cli/formula'
require 'chemistrykit/cli/beaker'
require 'chemistrykit/cli/helpers/formula_loader'

module ChemistryKit
  module CLI

    class Generate < Thor
      register(ChemistryKit::CLI::FormulaGenerator, 'formula', 'formula [NAME]', 'generates a page object')
      register(ChemistryKit::CLI::BeakerGenerator, 'beaker', 'beaker [NAME]', 'generates a beaker')
    end

    class CKitCLI < Thor

      register(ChemistryKit::CLI::New, 'new', 'new [NAME]', 'Creates a new ChemistryKit project')
      check_unknown_options!
      default_task :help

      desc "generate SUBCOMMAND", "generate <formula> or <beaker> [NAME]"
      subcommand "generate", Generate

      desc "brew", "Run ChemistryKit"
      method_option :params, :type => :hash
      method_option :tag, :default => ['depth:shallow'], :type => :array
      method_option :config, :default => 'config.yaml', :aliases => "-c", :desc => "Supply alternative config file."
      def brew
        load_config
        require 'chemistrykit/shared_context'
        pass_params if options['params']
        turn_stdout_stderr_on_off
        set_logs_dir
        load_page_objects
        setup_tags
        rspec_config
        run_rspec
      end

      protected

      def pass_params
        options['params'].each_pair do |key, value|
          ENV[key] = value
        end
      end

      def load_page_objects
        loader = ChemistryKit::CLI::Helpers::FormulaLoader.new
        loader.get_formulas(File.join(Dir.getwd, 'formulas')).each {|file| require file }
      end

      def set_logs_dir
        ENV['CI_REPORTS'] = File.join(Dir.getwd, 'evidence')
      end

      def turn_stdout_stderr_on_off
        ENV['CI_CAPTURE'] = 'on'
      end

      def load_config
        #not wild about using an env variable here... but maybe it makes sense
        #just not sure how to inject it into the shared context.
        ENV['CONFIG_FILE'] = options['config']
      end

      def setup_tags
        @tags = {}
        options['tag'].each do |tag|
          filter_type = tag.start_with?('~') ? :exclusion_filter : :filter

          name, value = tag.gsub(/^(~@|~|@)/, '').split(':')
          name = name.to_sym

          value = true if value.nil?

          @tags[filter_type] ||= {}
          @tags[filter_type][name] = value
        end
      end

      def rspec_config #Some of these bits work and others don't
        RSpec.configure do |c|
          c.treat_symbols_as_metadata_keys_with_true_values = true
          c.filter_run @tags[:filter] unless @tags[:filter].nil?
          c.filter_run_excluding @tags[:exclusion_filter] unless @tags[:exclusion_filter].nil?
          c.include ChemistryKit::SharedContext
          c.order = 'random'
          c.default_path = 'beakers'
          c.pattern = '**/*_beaker.rb'
        end
      end

      def run_rspec
        RSpec::Core::Runner.run(Dir.glob(File.join(Dir.getwd)))
      end

    end
  end
end
