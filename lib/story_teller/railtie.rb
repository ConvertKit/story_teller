module StoryTeller
  require "story_teller/middleware"

  class Railtie < ::Rails::Railtie
    config.story_teller = ActiveSupport::OrderedOptions.new
    config.story_teller.dispatcher = ActiveSupport::OrderedOptions.new

    initializer "story_teller.configuration" do |app|
      StoryTeller.configure!(app.config.story_teller)
    end

    initializer "story_teller.middleware" do |app|
      app.config.middleware.insert_after "RequestStore::Middleware", StoryTeller::Middleware
    end

    initializer "story_teller.jobs" do
      if defined?(::Sidekiq)
        require "story_teller/sidekiq"
        ::Sidekiq.configure_server do |config|
          config.server_middleware do |chain|
            chain.add StoryTeller::Sidekiq
          end
        end
      end
    end
  end
end
