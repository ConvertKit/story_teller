class StoryTeller::Error < StoryTeller::Story
  def initialize(error)
    super(message: "Unhandled Exception: #{error.message}")
    @severity = StoryTeller::Story::ERROR_LEVEL
  end
end
