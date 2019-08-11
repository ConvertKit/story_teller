class StoryTeller::Story
  INFO_LEVEL = 3
  ERROR_LEVEL = 4

  class StoryAttributeMissingError < StandardError; end

  attr_accessor :timestamp
  attr_reader :attributes, :type, :message, :severity

  def initialize(attrs = {})
    if attrs.is_a?(String)
      attrs = { message: attrs }
    end

    @attributes = StoryTeller::Attributes.new(attrs)

    unless @attributes.valid?
      raise StoryAttributeMissingError, "Invalid story. Requires a message"
    end

    @severity = INFO_LEVEL
    @timestamp = Time.now.utc
  end

  def to_hash
    {
      severity: severity,
      timestamp: timestamp.strftime("%s%N"),
      message: attributes.message,
      data: attributes.to_hash
    }
  end
end
