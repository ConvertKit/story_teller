module StoryTeller::Dispatchers
  class Test
    attr_accessor :should_raise_error

    attr_reader :events

    def initialize(*)
      @events = []
    end

    def submit(data)
      @events.push(data)
      if should_raise_error
        raise StandardError
      end
    end
  end
end
