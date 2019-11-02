# Not a threadsafe class
#
class StoryTeller::Tracer
  def initialize(config)
    whitelist_paths = config.white_list_paths
    whitelist_paths.freeze

    @trace_point = TracePoint.new(:call) do |tracepoint|
      if included?(whitelist_paths, tracepoint.path)
        trace = StoryTeller::Trace.new(
          tracepoint: tracepoint,
          timepoint: @timepoint
        )
        StoryTeller.tell(trace)
      end

      @timepoint = Time.now
    end
  end

  def trace(chapter, &block)
    @timepoint = Time.now

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
