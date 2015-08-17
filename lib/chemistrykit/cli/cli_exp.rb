# Encoding: utf-8

require 'thor'
require 'rspec'
require 'rspec/retry'
require 'rspec/parallel'
require 'chemistrykit/cli/new'
require 'chemistrykit/cli/formula'
require 'chemistrykit/cli/beaker'
require 'chemistrykit/cli/helpers/formula_loader'
require 'chemistrykit/catalyst'
require 'chemistrykit/formula/base'
require 'chemistrykit/formula/formula_lab'
require 'chemistrykit/chemist/repository/csv_chemist_repository'
require 'selenium_connect'
require 'chemistrykit/configuration'
require 'parallel_tests'
require 'chemistrykit/parallel_tests/rspec/runner'
require 'chemistrykit/rspec/j_unit_formatter'

require 'rspec/core/formatters/html_formatter'
require 'chemistrykit/rspec/html_formatter'

require 'chemistrykit/reporting/html_report_assembler'
require 'chemistrykit/split_testing/provider_factory'

require 'rubygems'
require 'logging'
require 'rspec/logging_helper'

module ChemistryKit
  module CLI

    # Registers the formula and beaker commands
    class Generate2 < Thor
      register(ChemistryKit::CLI::FormulaGenerator, 'formula', 'formula [NAME]', 'generates a page object')
      register(ChemistryKit::CLI::BeakerGenerator, 'beaker', 'beaker [NAME]', 'generates a beaker')
    end

    # Main Chemistry Kit CLI Class
    class CKitCLI2 < Thor

      register(ChemistryKit::CLI::New, 'new', 'new [NAME]', 'Creates a new ChemistryKit project')

      check_unknown_options!
      default_task :help

      desc 'generate SUBCOMMAND', 'generate <formula> or <beaker> [NAME]'
      subcommand 'generate', Generate

      desc 'tags', 'Lists all tags in use in the test harness.'
      def tags
        puts "TAGS"
        beakers = Dir.glob(File.join(Dir.getwd, 'beakers/**/*')).select { |file| !File.directory?(file) }
        ::RSpec.configure do |c|
          c.add_setting :used_tags
          c.before(:suite) { ::RSpec.configuration.used_tags = [] }
          c.around(:each) do |example|
            standard_keys = [:example_group, :example_group_block, :description_args, :caller, :execution_result, :full_description]
            example.metadata.each do |key, value|
              tag = "#{key}:#{value}" unless standard_keys.include?(key)
              ::RSpec.configuration.used_tags.push tag unless ::RSpec.configuration.used_tags.include?(tag) || tag.nil?
            end
          end
          c.after(:suite) do
            puts "\nTags used in harness:\n\n"
            puts ::RSpec.configuration.used_tags.sort
          end
        end
        ::RSpec::Core::Runner.run(beakers)
      end

      desc 'brew', 'Run ChemistryKit'
      method_option :params, type: :hash
      method_option :tag, type: :array
      method_option :config, default: 'config.yaml', aliases: '-c', desc: 'Supply alternative config file.'
      # TODO: there should be a facility to simply pass a path to this command
      method_option :beakers, aliases: '-b', type: :array
      method_option :results_file, aliases: '-r', default: false, desc: 'Specifiy the name of your results file.'
      method_option :all, default: false, aliases: '-a', desc: 'Run every beaker.', type: :boolean
      method_option :retry, default: false, aliases: '-x', desc: 'How many times should a failing test be retried.'

      def brew
        config = load_config options['config']
        # TODO: perhaps the params should be rolled into the available
        # config object injected into the system?
        pass_params if options['params']

        # replace certain config values with run time flags as needed
        config = override_configs options, config

        load_page_objects



        if options['beakers']
          beakers = options['beakers']
        else
          # beakers default to everything
          beakers = Dir.glob(File.join(Dir.getwd, 'beakers/**/*')).select { |file| !File.directory?(file) }
        end

        setup_tags(options['tag'])

        # configure rspec
        rspec_config(config)
        if config.concurrency > 1
          exit_code = run_rspec_parallel beakers, config.concurrency
        else
          exit_code = run_rspec beakers
        end  
        process_html
        exit_code
      end

      protected

      def process_html
        results_folder = File.join(Dir.getwd, 'evidence')
        output_file = File.join(Dir.getwd, 'evidence', 'final_results.html')
        assembler = ChemistryKit::Reporting::HtmlReportAssembler.new(results_folder, output_file)
        assembler.assemble
      end

      def override_configs(options, config)
        # TODO: expand this to allow for more overrides as needed
        config.retries_on_failure = options['retry'].to_i if options['retry']
        config
      end

      def pass_params
        options['params'].each_pair do |key, value|
          ENV[key] = value
        end
      end

      def load_page_objects
        loader = ChemistryKit::CLI::Helpers::FormulaLoader.new
        loader.get_formulas(File.join(Dir.getwd, 'formulas')).each { |file| require file }
      end

      def load_config(file_name)
        config_file = File.join(Dir.getwd, file_name)
        ChemistryKit::Configuration.initialize_with_yaml config_file
      end

      def setup_tags(selected_tags)
        @tags = {}
        selected_tags.each do |tag|
          filter_type = tag.start_with?('~') ? :exclusion_filter : :filter

          name, value = tag.gsub(/^(~@|~|@)/, '').split(':')
          name = name.to_sym

          value = true if value.nil?

          @tags[filter_type] ||= {}
          @tags[filter_type][name] = value
        end unless selected_tags.nil?
      end

      # rubocop:disable MethodLength
      def rspec_config(config) # Some of these bits work and others don't
        puts 'RSPEC CONFIG'
        ::RSpec.configure do |c|
          c.capture_log_messages

          c.treat_symbols_as_metadata_keys_with_true_values = true
          unless options[:all]
            c.filter_run @tags[:filter] unless @tags[:filter].nil?
            c.filter_run_excluding @tags[:exclusion_filter] unless @tags[:exclusion_filter].nil?
          end

          c.before(:all) do
            @things = {}
            ENV['BASE_URL'] = config.base_url # assign base url to env variable for formulas 
          end

          c.around(:each) do |example|
            test_name = example.metadata[:full_description].downcase.strip.gsub(' ', '_').gsub(/[^\w-]/, '')
            @things[test_name] = Thing.new(config)
            driver = @things[test_name].around_hook(example)
            #@things.around_hook(example)
            chemist_data_paths = Dir.glob(File.join(Dir.getwd, 'chemists', '*.csv'))
            repo = ChemistryKit::Chemist::Repository::CsvChemistRepository.new chemist_data_paths
            # make the formula lab available
            @formula_lab = ChemistryKit::Formula::FormulaLab.new driver, repo, File.join(Dir.getwd, 'formulas')
          end

          c.before(:each) do
            test_name = example.metadata[:full_description].downcase.strip.gsub(' ', '_').gsub(/[^\w-]/, '')
            @things[test_name].before_hook
            #@things.before_hook
          end

          c.after(:each) do
            test_name = example.description.downcase.strip.gsub(' ', '_').gsub(/[^\w-]/, '')
            @things[test_name].after_hook(example)
            #@things.after_hook(example)
          end
          
          #c.order = 'random'
          c.default_path = 'beakers'
          c.pattern = '**/*_beaker.rb'
          c.output_stream = $stdout
          c.add_formatter 'progress'

          # for rspec-retry
          c.verbose_retry = true # for rspec-retry
          c.default_retry_count = config.retries_on_failure

          html_log_name = 'results.html'
          c.add_formatter(ChemistryKit::RSpec::HtmlFormatter, File.join(Dir.getwd, config.reporting.path, html_log_name))

          # TODO: this is messy... there should be a cleaner way to hook various reporter things.
          junit_log_name = 'junit.xml'
          c.add_formatter(ChemistryKit::RSpec::JUnitFormatter, File.join(Dir.getwd, config.reporting.path, junit_log_name))
        end
      end
      # rubocop:enable MethodLength

      def run_rspec_parallel(beakers, concurrency)
        args = beakers + ['--parallel-test', concurrency.to_s]
        ::RSpec::Parallel::Runner.run(args)
      end
    
      def run_rspec(beakers)
        ::RSpec::Core::Runner.run(beakers)
      end

      class Thing < Thor
        register(ChemistryKit::CLI::New, 'new', 'new [NAME]', 'Creates a new ChemistryKit project')
        desc 'generate SUBCOMMAND', 'generate <formula> or <beaker> [NAME]'
        subcommand 'generate', Generate

        def initialize(config)
          @config = config
        end

        desc 'around_hook', 'Start example'
        def around_hook(example)
          beaker_name = example.metadata[:example_group][:description_args].first.downcase.strip.gsub(' ', '_').gsub(/[^\w-]/, '')
          test_name = example.metadata[:full_description].downcase.strip.gsub(' ', '_').gsub(/[^\w-]/, '')
          puts "EXAMPLE " + test_name

            # override log path with be beaker sub path
          sc_config = @config.selenium_connect.dup
          sc_config[:log] += "/#{beaker_name}"
          beaker_path = File.join(Dir.getwd, sc_config[:log])
          Dir.mkdir beaker_path unless File.exists?(beaker_path)
          sc_config[:log] += "/#{test_name}"
          @test_path = File.join(Dir.getwd, sc_config[:log])
          Dir.mkdir @test_path unless File.exists?(@test_path)
          # set the tags and permissions if sauce
          if sc_config[:host] == 'saucelabs' || sc_config[:host] == 'appium'
            tags = example.metadata.reject do |key, value|
                [:example_group, :example_group_block, :description_args, :caller, :execution_result, :full_description].include? key
            end
            sauce_opts = {}
            sauce_opts.merge!(public: tags.delete(:public)) if tags.key?(:public)
            sauce_opts.merge!(tags: tags.map { |key, value| "#{key}:#{value}"}) unless tags.empty?

            if sc_config[:sauce_opts]
              sc_config[:sauce_opts].merge!(sauce_opts) unless sauce_opts.empty?
            else
              sc_config[:sauce_opts] = sauce_opts unless sauce_opts.empty?
            end
          end

            # configure and start sc
          configuration = SeleniumConnect::Configuration.new sc_config
          @sc = SeleniumConnect.start configuration
          @job = @sc.create_job # create a new job
          @driver = @job.start name: test_name

          # TODO: this is messy, and could be refactored out into a static on the lab
          puts "FORMULA: " + File.join(Dir.getwd, 'formulas')
          example.run
          @driver
        end

        desc 'before_hook', 'Setup driver'
        def before_hook
          if @config.basic_auth
            @driver.get(@config.basic_auth.http_url) if @config.basic_auth.http?
            @driver.get(@config.basic_auth.https_url) if @config.basic_auth.https?
          end
  
          if @config.split_testing
            ChemistryKit::SplitTesting::ProviderFactory.build(@config.split_testing).split(@driver)
          end
        end

        desc 'after_hook', 'Kill processes'
        def after_hook(example)
          if example.exception.nil? == false
            @job.finish failed: true, failshot: @config.screenshot_on_fail
          else
            @job.finish passed: true
          end
          @sc.finish
          log = File.open(File.join(@test_path, 'test_steps.log'), 'w')

          #lines  = @log_output.readlines
          #lines.each do |line|
          #  log.write(line)
          #end
          log.close
        end
      end
    end # CkitCLI
  end # CLI
end # ChemistryKit
