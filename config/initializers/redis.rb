require 'redis'

$redis = Redis.new(:host => ENV.fetch('REDIS_HOST') { 'localhost' }, :db => 0, :namespace => 'cache')