module StoryTeller::Dispatchers
  class UnknownDispatcherError < StandardError; end

  def self.[](type)
    case type
    when :agent
      require "story_teller/dispatchers/agent"
      StoryTeller::Dispatchers::Agent
    when :logger
      require "story_teller/dispatchers/logger"
      StoryTeller::Dispatchers::Logger
    when :test
      require "story_teller/dispatchers/test"
      StoryTeller::Dispatchers::Test
    else
      raise UnknownDispatcherError.new("Unknown type: #{type}")
    end
  end
end
