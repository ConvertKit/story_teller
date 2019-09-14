class StoryTeller::Trace < StoryTeller::Story
  def initialize(point)
    super(message: "A trace")
    @severity = StoryTeller::Story::TRACE_LEVEL
  end
end
