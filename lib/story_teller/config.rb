# frozen_string_literal: true

require "logger"

class StoryTeller::Config
  SEMAPHORE = Mutex.new

  class << self
    def configure!(config = {})
      SEMAPHORE.synchronize do
        @logger = config.fetch(:logger, Logger.new(STDERR))

        @dispatcher = {}

        config.fetch(:dispatcher, {}).each_pair do |key, value|
          @dispatcher[key.to_sym] = value
        end

        @dispatcher[:type] ||= :logger

        @configured = true
      end
    end

    def configured?
      SEMAPHORE.synchronize do
        @configured
      end
    end

    def logger
      configure! unless configured?

      SEMAPHORE.synchronize do
        @logger
      end
    end

    def dispatcher
      configure! unless configured?

      SEMAPHORE.synchronize do
        @dispatcher
      end
    end
  end
end
