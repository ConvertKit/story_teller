# frozen_string_literal: true

require "logger"

class StoryTeller::Config
  SEMAPHORE = Mutex.new

  class << self
    def configure!(config = {})
      SEMAPHORE.synchronize do
        @logger = config.fetch(:logger, Logger.new(STDERR))
        @tracer = config.fetch(:tracer, StoryTeller::Tracer)

        @dispatcher = {}

        config.fetch(:dispatcher, {}).each_pair do |key, value|
          @dispatcher[key.to_sym] = value
        end

        @dispatcher[:type] ||= :logger

        @configured = true
      end
    end

    def configured?
      @configured
    end

    def logger
      configure! unless configured?

      @logger
    end

    def dispatcher
      configure! unless configured?

      @dispatcher
    end

    def tracer
      configure! unless configured?

      @tracer
    end
  end
end
