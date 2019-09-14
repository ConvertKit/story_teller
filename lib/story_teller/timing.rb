class StoryTeller::Timing < StoryTeller::Story
  def initialize(duration)
    super(
      duration: duration,
      message: "%{duration}ms")

    @severity = StoryTeller::Story::TIMING_LEVEL
  end
end
