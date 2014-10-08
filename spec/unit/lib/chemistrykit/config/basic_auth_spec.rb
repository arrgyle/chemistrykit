# Encoding: utf-8

require 'spec_helper'
require 'chemistrykit/config/basic_auth'

describe ChemistryKit::Config::BasicAuth do

  VALID_USERNAME = 'user'
  VALID_PASSWORD = 'pass'
  VALID_URL = 'http://testsite.com'
  VALID_HTTP_PATH = '/'
  VALID_HTTPS_PATH = '/secure'

  before(:each) do
    @opts = {
      username: VALID_USERNAME,
      password: VALID_PASSWORD,
      base_url: VALID_URL,
      http_path: VALID_HTTP_PATH,
      https_path: VALID_HTTPS_PATH
      }
      @basic_auth = ChemistryKit::Config::BasicAuth.new(@opts)
  end

  it 'should be initialized with an hash of options' do
    @basic_auth.should be_an_instance_of ChemistryKit::Config::BasicAuth
  end

  it 'should get the basic configuration values' do
    @basic_auth.username.should eq VALID_USERNAME
    @basic_auth.password.should eq VALID_PASSWORD
    @basic_auth.base_url.should eq VALID_URL
    @basic_auth.http_path.should eq VALID_HTTP_PATH
    @basic_auth.https_path.should eq VALID_HTTPS_PATH
  end

  it 'should raise an error for invalid config parameters' do
    expect do
      ChemistryKit::Config::BasicAuth.new(@opts.merge(bad: 'value'))
    end.to raise_error(ArgumentError, 'The config key: "bad" is unknown!')
  end

  it 'should report on the availability of http path' do
    @basic_auth.http?.should be_true
    basic_auth = ChemistryKit::Config::BasicAuth.new(@opts.merge(http_path: nil))
    basic_auth.http?.should be_false
    basic_auth = ChemistryKit::Config::BasicAuth.new({})
    basic_auth.http?.should be_false
  end

  it 'should report on the availability of https path' do
    @basic_auth.https?.should be_true
    basic_auth = ChemistryKit::Config::BasicAuth.new(@opts.merge(https_path: nil))
    basic_auth.https?.should be_false
    basic_auth = ChemistryKit::Config::BasicAuth.new({})
    basic_auth.https?.should be_false
  end

  it 'should return the http url' do
    @basic_auth.http_url.should eq "http://#{VALID_USERNAME}:#{VALID_PASSWORD}@testsite.com"
  end

  it 'should return the http url by default' do
    basic_auth = ChemistryKit::Config::BasicAuth.new(@opts.merge(http_path: nil))
    basic_auth.http_url.should eq "http://#{VALID_USERNAME}:#{VALID_PASSWORD}@testsite.com"
  end

  it 'should return the https url' do
    @basic_auth.https_url.should eq "https://#{VALID_USERNAME}:#{VALID_PASSWORD}@testsite.com/secure"
  end

  it 'should return the https url by default' do
    basic_auth = ChemistryKit::Config::BasicAuth.new(@opts.merge(https_path: nil))
    basic_auth.https_url.should eq "https://#{VALID_USERNAME}:#{VALID_PASSWORD}@testsite.com"
  end

end
