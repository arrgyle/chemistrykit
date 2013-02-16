require 'chemistrykit/sauce'
require 'rspec/core/shared_context'
require 'restclient'
require File.join(Dir.getwd, '_config', 'requires')

module ChemistryKit
  module SharedContext
    extend RSpec::Core::SharedContext
    include ChemistryKit::Sauce

    attr_accessor :magic_keys, :example_tags, :payload

    # This needs to be tested
    def choose_executor
      if CHEMISTRY_CONFIG['saucelabs']['ondemand']
        @executor = sauce_executor
      else
        @executor = 'http://' + CHEMISTRY_CONFIG['webdriver']['server_host'] + ":" + CHEMISTRY_CONFIG['webdriver']['server_port'].to_s + '/wd/hub'
      end
    end

    def capabilities
      Selenium::WebDriver::Remote::Capabilities.send(CHEMISTRY_CONFIG['webdriver']['browser'])
    end

    def driver(an_executor, capabilities)
      if CHEMISTRY_CONFIG['chemistrykit']['run_locally']
        @driver = Selenium::WebDriver.for(CHEMISTRY_CONFIG['webdriver']['browser'].to_sym)
      else
        @driver = ChemistryKit::WebDriver::Driver.new(:url => an_executor, :desired_capabilities => capabilities)
      end
    end

    before(:all) do
      if CHEMISTRY_CONFIG['saucelabs']['ondemand']
        if CHEMISTRY_CONFIG['webdriver']['browser'] != 'chrome'
          capabilities[:version] = CHEMISTRY_CONFIG['saucelabs']['version']
        else
          capabilities[:platform] = CHEMISTRY_CONFIG['saucelabs']['platform']
        end
        set_sauce_keys
      end
      choose_executor
    end

    before(:each) do
      driver(@executor, capabilities)
    end

    after(:each) do
      if CHEMISTRY_CONFIG['saucelabs']['ondemand']
        @session_id = @driver.session_id
        @driver.quit
        setup_data_for_sauce
        create_payload
        post_to_sauce
      else
        @driver.quit
      end
    end

  end
end
