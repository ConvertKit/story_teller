class StoryTeller::Book
  class MissingChapterError < StandardError; end
  UUID_CHAPTER_TITLE = "UUID".freeze

  attr_reader :chapters, :dispatcher

  def initialize(dispatcher:, uuid: nil)
    @dispatcher = dispatcher
    @uuid = uuid
    @chapters = []
  end

  def empty?
    @chapters.empty?
  end

  def chapter(title:, subtitle: nil)
    chapter = start!(title, subtitle)

    begin
      returned_value = nil
      returned_value = yield(chapter) if block_given?
    rescue StandardError => error
      if error != chapter.uncaught_error
        tell(StoryTeller::Error.new(error))
      end
      raise error
    ensure
      finish!(error: error)
      returned_value
    end
  end

  def tell(story = {})
    unless story.is_a? StoryTeller::Story
      story = StoryTeller::Story.new(story)
    end

    begin
      @dispatcher.submit(to_json(story))
    rescue Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError => e
      story = StoryTeller::Error.new(e)
      @dispatcher.submit(to_json(story))
    end

    nil
  end

  def current_chapter
    if empty?
      chapter = StoryTeller::Chapter.new(title: UUID_CHAPTER_TITLE, subtitle: uuid)
      @chapters.push(chapter)
      return current_chapter
    end

    @chapters.last
  end

  def uuid
    @uuid ||= SecureRandom.uuid
  end

  private

  def start!(title, subtitle)
    chapter = StoryTeller::Chapter.new(title: title, subtitle: subtitle)

    chapter.merge(current_chapter.to_hash)

    @chapters.push(chapter)
    chapter
  end

  def finish!(error: nil)
    chapter = @chapters.pop
    current_chapter.uncaught_error = error
    chapter
  end

  def to_json(story)
    hash = story.to_hash
    hash[:data] = hash.fetch(:data, {}).merge(current_chapter.to_hash)
    hash.to_json
  end
end
