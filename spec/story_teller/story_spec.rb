require "story_teller"

describe StoryTeller::Story do
  context "initialize" do
    it "will raise an error if no message was set for this story" do
      expect {
        StoryTeller::Story.new
      }.to raise_error(StoryTeller::Story::StoryAttributeMissingError)
    end

    it "handles a string as argument and takes it as a message" do
      message = "A message"
      story = StoryTeller::Story.new(message)
      expect(story.to_hash[:message]).to eq(message)
    end
  end

  context "to_hash(options = {})" do
    it "will include a timestamp with nanoseconds" do
      time = Time.now.utc
      story = StoryTeller::Story.new(message: "test")
      story.timestamp = time
      expect(story.timestamp).to be_within(1.second).of(time)
      expect(story.to_hash[:timestamp].end_with?(time.nsec.to_s)).to eq(true)
    end

    it "will include the message" do
      message = "A message"
      story = StoryTeller::Story.new(message: message)
      story.timestamp = Time.now.utc
      expect(story.to_hash[:message]).to eq(message)
    end

    it "will include attributes as a hash" do
      story = StoryTeller::Story.new(message: "test")
      story.timestamp = Time.now.utc
      expect(story.to_hash.has_key?(:data)).to eq(true)
      expect(story.to_hash[:data]).to be_a(Hash)
    end
  end
end
