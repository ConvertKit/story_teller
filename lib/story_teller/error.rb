class StoryTeller::Error < StoryTeller::Story
  def initialize(error)
    super({
      message: "Unhandled Exception: #{error.message}"
    }, StoryTeller::ERROR_LEVEL)
  end
end
