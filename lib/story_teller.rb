module StoryTeller
  require "story_teller/config"
  require "story_teller/dispatchers"
  require "story_teller/book"
  require "story_teller/chapter"
  require "story_teller/story"
  require "story_teller/error"
  require "story_teller/attributes"
  require "story_teller/message"

  class << self
    def configure!(config = {})
      StoryTeller::Config.configure!(config)
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
        book = Book.new(dispatcher: dispatcher, tracer: tracer)
        Thread.current[:story_teller] = book
      end

      book
    end

    def tracer
      @tracer ||= begin
        StoryTeller::Config.tracer.new
      end
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
