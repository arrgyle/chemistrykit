require 'rspec'

module ChemistryKit
  class RspecConfig
    RSpec.configure do |t|
      t.spec_opts = ['--options', "./.rspec"]
      t.filter_run tags[:filter] unless tags[:filter].nil?
      t.filter_run_excluding tags[:exclusion_filter] unless tags[:exclusion_filter].nil?
      t.filter_run_including :depth => 'shallow'
      t.include ChemistryKit::SharedContext
      t.order = 'random'
      t.spec_files = FileList['spec/**/*_spec.rb']
    end
  end
end
