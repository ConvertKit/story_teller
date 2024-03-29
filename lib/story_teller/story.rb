class StoryTeller::Story
  attr_accessor :timestamp
  attr_reader :attributes, :type, :message, :level

  def initialize(attrs = {}, level = StoryTeller::STORY_LEVEL)
    if attrs.is_a?(String)
      attrs = { message: attrs }
    end

    @attributes = StoryTeller::Attributes.new(attrs)

    @level = level
    @timestamp = Time.now.utc
  end

  def to_hash
    {
      story_uuid: SecureRandom.uuid,
      level: level,
      timestamp: timestamp.strftime("%s%N"),
      message: attributes.message,
      data: attributes.to_hash
    }
  end
end
