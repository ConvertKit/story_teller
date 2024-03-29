module StoryTeller
  require "story_teller/config"
  require "story_teller/dispatchers"
  require "story_teller/book"
  require "story_teller/chapter"
  require "story_teller/level"
  require "story_teller/story"
  require "story_teller/error"
  require "story_teller/attributes"
  require "story_teller/message"

  STORY_LEVEL = 1 << 0
  ANALYTIC_LEVEL = 1 << 1
  ERROR_LEVEL =  1 << 2

  LEVELS = [
    ANALYTIC_LEVEL,
    STORY_LEVEL,
    ERROR_LEVEL
  ]

  class InvalidLevelError < StandardError; end

  class << self
    def configure!(config = {})
      StoryTeller::Config.configure!(config)
    end

    def level(*levels)
      levels.each do |level|
        unless LEVELS.include?(level)
          raise InvalidLevelError.new(level)
        end
      end

      StoryTeller::Level.new(levels.reduce(&:|))
    end

    def tell(story = {})
      book.tell(story)
    end

    def chapter(title:, subtitle: nil, &block)
      book.chapter(title: title, subtitle: subtitle, &block)
    end

    def uuid
      book.uuid
    end

    def to_json
      book.to_json
    end

    def empty?
      book.empty?
    end

    def clear!
      Thread.current[:story_teller] = nil
    end

    private

    def book
      book = Thread.current[:story_teller]
      if book.nil?
        book = Book.new(dispatcher: dispatcher)
        Thread.current[:story_teller] = book
      end

      book
    end

    def dispatcher
      @dispatcher ||= begin
        config = StoryTeller::Config.dispatcher
        StoryTeller::Dispatchers[config[:type]].new(config.except(:type))
      end
    end
  end
end

if defined?(Rails)
  require "story_teller/railtie"
end
