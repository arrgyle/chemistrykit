require 'rspec'
require 'redis'

describe 'User Queue' do

  #GOAL:
  ## A user queue that works across tests
  ## and contains type and credentials
  ### (email, password, name) for each account
  #
  #Assumed workflow:
  ## search queue by type to see if an account is present
  ### if so, pop from the queueu and use -- returning when done
  ### if not, create a new user and add it to the queue

  before(:all) do

    # START THE REDIS SERVER in bin/redis-server
    ## e.g.`bin/redis-server &`

    @redis = Redis.new
    @user = Hash.new

    # Set data in redis
    # Assumed info populated from the existing chemist CSV when {{UIID}} is used
    # Since Hashes in redis don't support pop/push queueing, using an 'in_use' flag instead
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
    result = system('ps ax | grep redis-server').to_s
    pid = result.scan(/^\d*/).first
    system("kill -9 #{pid}")
  end


  it 'returns a correctly populated user object' do
    @user[:id].class.should == String
    @user[:payload].class.should == Hash
    @user[:payload]['email'].should =~ /@arrgyle.com/
  end

  it 'updates the user object in redis correct' do
    # Updates the user
    @redis.hset(@user[:id], 'type', 'pro')
    @redis.hset(@user[:id], 'in_use', 'no')

    @redis.hget(@user[:id], 'type').should == 'pro'
    @redis.hget(@user[:id], 'in_use').should == 'no'
  end

end
