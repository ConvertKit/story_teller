class StoryTeller::Level
  def initialize(levels)
    @levels = levels
  end

  def tell(story = {})
    data = {}
    if story.is_a? StoryTeller::Story
      data = data.merge(story.attributes.to_hash)
      data = data.merge(message: story.attributes.message)
    else
      data = story
    end

    story = StoryTeller::Story.new(data, @levels)

    StoryTeller.tell(story)
  end
end
