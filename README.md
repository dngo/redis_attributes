redis_attributes
================

A simple way to annotate ActiveRecord objects with properties that are stored in Redis instead of your relational database.

## Installation

Add this line to your application's Gemfile:

    gem 'redis_attributes'

And then execute:

    $ bundle install

## Usage

The `RedisAttributes` module depends on `Redis.current` (provided by the `redis` gem) being set.

To add RedisAttributes to your models just include `RedisAttributes` in your ActiveRecord class and use the
`define_redis_attributes` method to declare extra (optionally namespaced) properties for your objects.

```ruby
class User < ActiveRecord::Base
  include RedisAttributes

  define_redis_attributes do
    define :display_name
    define :active_flag
    define :age
    define :temperature
  end

end

user.display_name = "davngo"
