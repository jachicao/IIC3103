if ENV["RAILS_ENV"] != "production"

 # return;

end

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://" + ENV.fetch("REDIS_HOST") { "localhost" } + ":6379/1/cache" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://" + ENV.fetch("REDIS_HOST") { "localhost" } + ":6379/1/cache" }
end