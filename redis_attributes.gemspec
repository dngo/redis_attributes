require File.expand_path('../lib/redis_attributes/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "redis_attributes"
  gem.version       = RedisAttributes::VERSION
  gem.authors       = ["David Ngo"]
  gem.email         = ["david@venuenext.com"]
  gem.description   = %q{Add non-relational database attributes to your ActiveRecord objects with properties that are stored in Redis.}
  gem.summary       = %q{Thanks for using this, tool.}
  gem.homepage      = "http://github.com/dngo/redis_attributes"

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_development_dependency "byebug"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "sqlite3"

  gem.add_dependency "activesupport"
  gem.add_dependency "activerecord"
  gem.add_dependency "redis"
end
