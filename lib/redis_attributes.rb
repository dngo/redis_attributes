require 'active_support/concern'
require 'active_record'
require "redis"

class RedisWrapper
  METHODS = [:set, :get, :expire, :del]

  attr :redis

  def initialize(object, field_name, redis = Redis.current)
    object_id = object.uuid || object.id
    @key = "#{object.class.name}:#{object_id}:#{field_name}"
    @redis = redis
  end

  METHODS.each do |method|
    define_method(method) do |*args, &block|
      redis.send(method, @key, *args, &block)
    end
  end
end

module RedisAttributes
  extend ActiveSupport::Concern

  module ClassMethods
    def define_redis_attributes(&block)
      Attribute.new(self, block)
    end
  end

  class Attribute
    def initialize(klass, block)
      @klass = klass
      instance_exec(&block)
    end

    def define(attribute_name, options={})
      add_methods_to(@klass, attribute_name, options)
    end

    private

    def add_methods_to(klass, attribute_name, options)
      klass.class_eval do
        define_method("#{attribute_name}") do
          instance_variable_get("@#{attribute_name}") || begin
            value = RedisWrapper.new(self, attribute_name).get
            value = value.nil? ? Attribute.typecaster(options[:default]) : Attribute.typecaster(value)
            instance_variable_set("@#{attribute_name}", value)
          end
        end

        define_method("#{attribute_name}?") do
          !!send(attribute_name)
        end

        define_method("#{attribute_name}=") do |value|
          redis_attribute = RedisWrapper.new(self, attribute_name)
          redis_attribute.set(value.to_s)
          instance_variable_set("@#{attribute_name}", value)
          redis_attribute.expire(options[:expire].to_i) if options[:expire]
        end

        after_destroy -> do
          redis_attribute = RedisWrapper.new(self, attribute_name)
          redis_attribute.del
        end
      end
    end

    def self.typecaster(value)
      case value
      when /^(true|t|yes|y|1)$/ #true
        true
      when /^(false|f|no|n|0)$/ #false
        false
      when /^\s*[+-]?((\d+_?)*\d+(\.(\d+_?)*\d+)?|\.(\d+_?)*\d+)(\s*|([eE][+-]?(\d+_?)*\d+)\s*)$/ #Float
        value.to_f
      when /\A[-+]?\d+\z/ #integer
        value.to_i
      else
        value
      end
    end
  end

end
