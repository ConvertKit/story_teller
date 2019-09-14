class StoryTeller::Book
  class MissingChapterError < StandardError; end
  UUID_CHAPTER_TITLE = "UUID".freeze

  attr_reader :chapters, :dispatcher

  def initialize(dispatcher:, uuid: nil, tracer: nil)
    @dispatcher = dispatcher
    @uuid = uuid
    @tracer = tracer
    @chapters = []
  end

  def empty?
    @chapters.empty?
  end

  def chapter(title:, subtitle: nil, &block)
    chapter = start!(title, subtitle, @tracer)
    value = chapter.run!(&block)
  ensure
    finish!
    return value
  end

  def tell(story = {})
    unless story.is_a? StoryTeller::Story
      story = StoryTeller::Story.new(story)
    end
    hash = story.to_hash
    hash[:data] = hash.fetch(:data, {}).merge(current_chapter.to_hash)

    @dispatcher.submit(hash.to_json)
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

  def start!(title, subtitle, tracer)
    chapter = StoryTeller::Chapter.new(title: title, subtitle: subtitle, tracer: tracer)

    chapter.merge(current_chapter.to_hash)

    @chapters.push(chapter)
    chapter
  end

  def finish!
    @chapters.pop
  end
end
