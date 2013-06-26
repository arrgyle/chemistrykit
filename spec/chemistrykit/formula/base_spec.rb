require 'spec_helper'

describe ChemistryKit::Formula::Base do

  before(:each) do
    #ideally we should mock the driver and not pass in nil
    driver = nil
    @formula_base = ChemistryKit::Formula::Base.new(driver)

    Dir.mkdir(File.join(TEST_TMP_PATH, 'catalyst'))
    @data_file = File.join(TEST_TMP_PATH, 'catalyst', 'catalyst_data.csv')
    File.open(@data_file, 'w') {|f| f.write("first_key,first_value\nsecond_key,second_value") }
    @catalyst = ChemistryKit::Catalyst.new(@data_file)
  end

  it 'Should allow a catalyst to be set.' do
    @formula_base.catalyst = @catalyst
    @formula_base.catalyst.should be_an_instance_of ChemistryKit::Catalyst
  end

    after(:each) do
    FileUtils.rm_rf(File.join(TEST_TMP_PATH, 'catalyst'))
  end

end
