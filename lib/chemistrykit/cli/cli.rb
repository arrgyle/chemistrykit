require "thor"
require 'rspec'
require 'chemistrykit/cli/generators'
require 'chemistrykit/cli/new'
require 'chemistrykit/cli/brew'

module ChemistryKit
  module CLI
    class CKitCLI < Thor

      # default_task :brew

      register(ChemistryKit::CLI::Generate, 'generate', 'generate [GENERATOR] [NAME]', 'generates something')
      register(ChemistryKit::CLI::New, 'new', 'new [NAME]', 'Creates a new ChemistryKit project')
      register(ChemistryKit::CLI::Brew, 'brew', 'brew [TAG]', 'Runs Chemistrykit')

    end
  end
end
