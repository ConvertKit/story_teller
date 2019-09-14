class StoryTeller::Tracer
  def initialize(config)
    whitelist_paths = config.white_list_paths
    whitelist_paths.freeze

    @trace_point = TracePoint.new(:call) do |point|
      if included?(whitelist_paths, point.path)
        StoryTeller.tell(StoryTeller::Trace.new(point))
      end

      next false 
    end
  end

  def trace(chapter, &block)
    @trace_point.enable do
      block.call(chapter)
    end
  end

  private

  def included?(allowed_paths, path)
    allowed_paths.any? do |allowed_path|
      allowed_path =~ path
    end
  end
end
