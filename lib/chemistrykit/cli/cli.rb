# Encoding: utf-8

require 'thor'
require 'rspec'
require 'rspec/retry'
#require 'rspec/parallel'
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
require 'chemistrykit/rspec/j_unit_formatter'

require 'rspec/core/formatters/html_formatter'
require 'chemistrykit/rspec/html_formatter'

require 'chemistrykit/reporting/html_report_assembler'

require 'rubygems'
require 'logging'
require 'rspec/logging_helper'

require 'fileutils'

module ChemistryKit
  module CLI
    # Main Chemistry Kit CLI Class
    class CKitCLI < Thor

      register(ChemistryKit::CLI::New, 'new', 'new [NAME]', 'Creates a new ChemistryKit project')

      check_unknown_options!
      default_task :help

      desc 'brew', 'Run ChemistryKit'
      method_option :params, type: :hash
      method_option :tag, type: :array
      method_option :config, default: 'config.yaml', aliases: '-c', desc: 'Supply alternative config file.'
      method_option :beakers, aliases: '-b', type: :array
      method_option :retry, default: false, aliases: '-x', desc: 'How many times should a failing test be retried.'
      method_option :all, default: false, aliases: '-a', desc: 'Run every beaker.', type: :boolean

      def brew
        config = load_config options['config']
        # TODO: perhaps the params should be rolled into the available
        # config object injected into the system?
        pass_params if options['params']

        # TODO: expand this to allow for more overrides as needed
        config.retries_on_failure = options['retry'].to_i if options['retry']

        load_page_objects

        # get those beakers that should be executed
        beakers = options['beakers'] ? options['beakers'] : Dir.glob(File.join(Dir.getwd, 'beakers/**/*')).select { |file| !File.directory?(file) }

        # if tags are explicity defined, apply them to all beakers
        setup_tags(options['tag'])

        # configure rspec
        rspec_config(config)

        # based on concurrency parameter run tests
        if config.concurrency > 1
          exit_code = run_parallel beakers, config.concurrency
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
      def rspec_config(config) 
        ::RSpec.configure do |c|
          c.before(:all) do
            @config = config
            ENV['BASE_URL'] = @config.base_url # assign base url to env variable for formulas
          end
          
          c.around(:each) do |example|
            # create the beaker name from the example data
            beaker_name = example.metadata[:example_group][:description_args].first.downcase.strip.gsub(' ', '_').gsub(/[^\w-]/, '')
            test_name = example.metadata[:full_description].downcase.strip.gsub(' ', '_').gsub(/[^\w-]/, '')

            # override log path with be beaker sub path
            sc_config = @config.selenium_connect.dup
            sc_config[:log] += "/#{beaker_name}"
            beaker_path = File.join(Dir.getwd, sc_config[:log])
            Dir.mkdir beaker_path unless File.exists?(beaker_path)
            sc_config[:log] += "/#{test_name}"
            @test_path = File.join(Dir.getwd, sc_config[:log])
            FileUtils.rm_rf(@test_path) if File.exists?(@test_path)
            Dir.mkdir @test_path

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
            chemist_data_paths = Dir.glob(File.join(Dir.getwd, 'chemists', '*.csv'))
            repo = ChemistryKit::Chemist::Repository::CsvChemistRepository.new chemist_data_paths
            # make the formula lab available
            @formula_lab = ChemistryKit::Formula::FormulaLab.new @driver, repo, File.join(Dir.getwd, 'formulas')
            example.run
          end
          c.before(:each) do
            if @config.basic_auth
              @driver.get(@config.basic_auth.http_url) if @config.basic_auth.http?
              @driver.get(@config.basic_auth.https_url) if @config.basic_auth.https?
            end
          end
          
          c.after(:each) do
            test_name = example.description.downcase.strip.gsub(' ', '_').gsub(/[^\w-]/, '')
            if example.exception.nil? == false
              @job.finish failed: true, failshot: @config.screenshot_on_fail
            else
              @job.finish passed: true
            end
            @sc.finish
            log = File.open(File.join(@test_path, 'test_steps.log'), 'w')

            lines  = @log_output.readlines
            lines.each do |line|
              log.write(line)
            end
            log.close
          end

          unless options[:all]
            c.filter_run @tags[:filter] unless @tags[:filter].nil?
            c.filter_run_excluding @tags[:exclusion_filter] unless @tags[:exclusion_filter].nil?
          end

          c.capture_log_messages
          c.treat_symbols_as_metadata_keys_with_true_values = true
          c.order = 'random'
          c.output_stream = $stdout
          # for rspec-retry
          c.verbose_retry = true
          c.default_retry_count = config.retries_on_failure

          c.add_formatter 'progress'
          
          html_log_name = "results_0.html"
          Dir.glob(File.join(Dir.getwd, config.reporting.path, "results*")).each { |f| File.delete(f) }
          c.add_formatter(ChemistryKit::RSpec::HtmlFormatter, File.join(Dir.getwd, config.reporting.path, html_log_name))

          junit_log_name = "junit_0.xml"
          Dir.glob(File.join(Dir.getwd, config.reporting.path, "junit*")).each { |f| File.delete(f) }
          c.add_formatter(ChemistryKit::RSpec::JUnitFormatter, File.join(Dir.getwd, config.reporting.path, junit_log_name))
        end
      end
      # rubocop:enable MethodLength

      def run_parallel(beakers, concurrency)
        require 'parallel_split_test/runner'
        args = beakers + ['--parallel-test', concurrency.to_s]
        ::ParallelSplitTest::Runner.run(args)
      end

      def run_rspec(beakers)
        ::RSpec::Core::Runner.run(beakers)
      end
    end # CkitCLI
  end # CLI
end # ChemistryKit
