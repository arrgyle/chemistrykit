require 'selenium-connect'
require 'rspec/core/shared_context'

module ChemistryKit
  module SharedContext
    extend RSpec::Core::SharedContext

      SeleniumConnect.configure do |c|
        c.config_file = File.join(Dir.getwd, '_config.yaml')
        # Grab the log location from the previously set environment variable to set
        # as a sane default, less than ideal.
        if ! c.log
          c.log = File.join(Dir.getwd, 'evidence', 'server.log')
        end
      end

      before(:each) do
        @driver = SeleniumConnect.start
      end

      after(:each) do
        SeleniumConnect.finish
      end

  end #SharedContext
end #ChemistryKit
