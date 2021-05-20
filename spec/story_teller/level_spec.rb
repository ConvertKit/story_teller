context StoryTeller::Level do
  before(:each) do
    StoryTeller.configure!(dispatcher: { type: :test })
  end

  describe "#tell" do
    it "dispatches the event" do
      level = StoryTeller::Level.new(1)
      level.tell(message: "Hello Level")

      dispatcher = StoryTeller.send(:book).dispatcher
      event = JSON.parse(dispatcher.events.last)

      expect(event["message"]).to eq("Hello Level")
    end

    it "sets the level of the message accordingly" do
      level = StoryTeller::Level.new(9)
      level.tell(message: "Hello Level")

      dispatcher = StoryTeller.send(:book).dispatcher
      event = JSON.parse(dispatcher.events.last)

      expect(event["level"]).to eq(9)
    end

    it "can accept a story" do
      level = StoryTeller::Level.new(5)
      story = StoryTeller::Story.new({
        message: "A message",
        some_value: "tada"
      })

      level.tell(story)

      dispatcher = StoryTeller.send(:book).dispatcher
      event = JSON.parse(dispatcher.events.last)

      expect(event["level"]).to eq(5)
      expect(event["message"]).to eq("A message")
      expect(event["data"]["some_value"]).to eq("tada")
    end

    it "can accept a hash" do
      level = StoryTeller::Level.new(1)
      level.tell(message: "Hello Level")

      dispatcher = StoryTeller.send(:book).dispatcher
      event = JSON.parse(dispatcher.events.last)

      expect(event["message"]).to eq("Hello Level")
    end
  end
end
