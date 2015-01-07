require 'spec_helper'
require 'sqlite3'
require 'active_record'

class User < ActiveRecord::Base
  include RedisAttributes

  establish_connection :adapter => 'sqlite3', :database => 'spec/foobar.db'
  connection.create_table :users, :force => true do |t|
    t.string :name
    t.string :uuid
    t.timestamps null: false
  end

  define_redis_attributes do
    define :display_name
    define :temp_value, expire: 1 
    define :active_flag
    define :age
    define :temperature
  end

end

describe RedisAttributes do
  let(:user) { User.create!(name: "david") }
  let(:redis) { Redis.current }

  context "blank context" do
    it "creates persistent attributes" do
      user.display_name = "davngo"
      User.find_by_name("david").display_name.should == "davngo"
    end
  end

  context "type inference" do
    it "works for booleans of all kinds" do
      user.active_flag = false
      User.find(user.id).active_flag.should == false
      user.active_flag = true
      User.find(user.id).active_flag.should == true
      user.active_flag = 1
      User.find(user.id).active_flag.should == true
      user.active_flag = 0
      User.find(user.id).active_flag.should == false
      user.active_flag = 't'
      User.find(user.id).active_flag.should == true
      user.active_flag = 'f'
      User.find(user.id).active_flag.should == false
    end

    it "works for integers" do
      user.age = 11
      User.find(user.id).age.should == 11
    end

    it "works for floats" do
      user.temperature = 99.9
      User.find(user.id).temperature.should == 99.9
    end
  end

  context "expire" do
    it "expires keys properly" do
      user.temp_value = "temp"
      User.find(user.id).temp_value.should == "temp"
      sleep(1)
      User.find(user.id).temp_value.should be_nil
    end
  end

  context "delete" do
    it "removes associated redis keys when object is destroyed" do
      user.display_name = "davngo"
      expect(redis.get("User:#{user.id}:display_name")).to eql("davngo")
      user.destroy
      expect(redis.get("User:#{user.id}:display_name")).to be_nil
    end
  end
end
