class StoryTeller::Trace < StoryTeller::Story
  def initialize(tracepoint:, :timepoint)
    seconds = Time.now - timepoint * 1000.0

    super(
      duration: seconds,
      message: tracepoint
    )
    @severity = StoryTeller::Story::TRACE_LEVEL
  end
end
