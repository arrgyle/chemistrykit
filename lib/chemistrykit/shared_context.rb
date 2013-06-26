require 'selenium-connect'
require 'rspec/core/shared_context'

module ChemistryKit
  module SharedContext
    extend RSpec::Core::SharedContext

      SeleniumConnect.configure do |c|
        c.config_file = File.join(Dir.getwd, ENV['CONFIG_FILE'])
      end

      before(:each) do
        @driver = SeleniumConnect.start
      end

      after(:each) do
        SeleniumConnect.finish
      end

  end #SharedContext
end #ChemistryKit
