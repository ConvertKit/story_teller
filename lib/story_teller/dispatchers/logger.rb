# frozen_string_literal: true

require "logger"

module StoryTeller::Dispatchers
  class Logger
    def initialize(config)
      @logger = config[:logger] || ::Logger.new(STDOUT)
    end

    def submit(json)
      @logger.info json
    end
  end
end
