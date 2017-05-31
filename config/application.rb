require_relative 'boot'

require 'rails/all'

#require 'sidekiq/api'

require 'rest-client'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Myapp
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.to_prepare do
      # Load application's model / class decorators
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      # Load application's view overrides
      Dir.glob(File.join(File.dirname(__FILE__), "../app/overrides/*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end
    config.cache_store = :redis_store, 'redis://' + ENV.fetch('REDIS_HOST') { 'localhost' } + ':6379/0/cache', { expires_in: 90.seconds }
    if ENV['DOCKER_RUNNING'] != nil
      config.active_job.queue_adapter = :sidekiq
    end
  end
end
