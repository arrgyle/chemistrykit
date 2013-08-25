# Encoding: utf-8

require 'rspec'
require 'redis'

describe 'User Queue with Redis Example' do

  #GOAL:
  ## A user queue that works across tests
  ## and contains type and credentials
  ### (email, password, name) for each account
  #
  # Assumed workflow:
  ## Search user queue by type to see if an account is available
  ### If so, remove it from the queueu and use it in the test
  #### Return when done
  ### If not, create a new user and add it to the queue

  before(:all) do
    bin_path = File.expand_path(File.join(File.dirname(__FILE__), '../bin'))
    @pid = fork do
      exec "#{bin_path}/redis-server"
    end

    # Adding tiny delay so tests don't try to connect to quickly and fail
    sleep 1

    @redis = Redis.new
    @user = Hash.new

    # Populate user queueu with data in Redis
    # Since Hashes in Redis do not support pop/push queueing,
    ## using an 'in_use' flag on the object instead
    @redis.hmset('user:1', 'email', 'dave+0001@arrgyle.com', 'type', 'lite', 'password', 'secret', 'in_use', 'no')
    @redis.hmset('user:2', 'email', 'dave+0002@arrgyle.com', 'type', 'lite', 'password', 'secret', 'in_use', 'no')

    # Returns a user object
    @redis.keys.each do |key|
      if @redis.hget(key, 'type') == 'lite'
        if @redis.hget(key, 'in_use') == 'no'
          @redis.hset(key, 'in_use', 'yes')
          @user[:id] = key
          @user[:payload] = @redis.hgetall(key)
          break
        end
      end
    end
  end

  after(:all) do
    Process.kill 'TERM', @pid
    Process.wait @pid
  end

  it 'returns a correctly populated user object' do
    @user[:id].class.should eq String
    @user[:payload].class.should eq Hash
    @user[:payload]['email'].should include('@arrgyle.com')
  end

  it 'updates the user object in redis correct' do
    # Updates the user
    @redis.hset(@user[:id], 'type', 'pro')
    @redis.hset(@user[:id], 'in_use', 'no')

    @redis.hget(@user[:id], 'type').should eq 'pro'
    @redis.hget(@user[:id], 'in_use').should eq 'no'
  end

end
