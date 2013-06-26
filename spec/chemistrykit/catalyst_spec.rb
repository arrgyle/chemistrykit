require 'spec_helper'

describe ChemistryKit::Catalyst do

  before(:each) do

    Dir.mkdir(File.join(TEST_TMP_PATH, 'catalyst'))
    @data_file = File.join(TEST_TMP_PATH, 'catalyst', 'catalyst_data.csv')
    File.open(@data_file, 'w') {|f| f.write("first_key,first_value\nsecond_key,second_value") }
    @catalyst = ChemistryKit::Catalyst.new(@data_file)
  end

  it 'Should take a csv file on initialization.' do
    @catalyst.should be_an_instance_of ChemistryKit::Catalyst
  end

  it 'Should respond to a named key.' do
    @catalyst.first_key.should be == 'first_value'
    @catalyst.second_key.should be == 'second_value'
  end

  it 'Should respond to a convienence method.' do
    @catalyst.get_value_for('second_key').should be == 'second_value'
    @catalyst.get_value_for('first_key').should be == 'first_value'
  end

  it 'Should throw an exception for a non existant key.' do
    expect {
      @catalyst.get_value_for('third_key')
    }.to raise_error("Unknown \"third_key\"")

    expect {
      @catalyst.third_key
    }.to raise_error("Unknown \"third_key\"")

  end

  after(:each) do
    FileUtils.rm_rf(File.join(TEST_TMP_PATH, 'catalyst'))
  end

end
