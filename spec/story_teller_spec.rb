require "story_teller"

describe StoryTeller do
  before(:each) do
    StoryTeller.configure!(dispatcher: { type: :test })
  end

  context ".chapter" do
    it "includes the UUID chapter even when starting logging with a specific chapter" do
      StoryTeller.chapter(title: "Something", subtitle: "Important") do
        StoryTeller.tell("yolo")
      end

      dispatcher = StoryTeller.send(:book).dispatcher
      event = JSON.parse(dispatcher.events.last)

      expect(event["data"][StoryTeller::Book::UUID_CHAPTER_TITLE]).to_not eq(nil)
    end

    it "allows passing only a title to the chapter" do
      StoryTeller.chapter(title: "Something") do
        StoryTeller.tell("A message")
      end

      dispatcher = StoryTeller.send(:book).dispatcher
      event = JSON.parse(dispatcher.events.last)

      expect(event["data"].key?("Something")).to eq(true)
    end
  end

  it "will recover from any StandardError" do
    expect {
      StoryTeller.tell
    }.to raise_error(StandardError)

    expect {
      StoryTeller.tell(
        message: "Test"
      )
    }.to_not raise_error(StandardError)
  end

  it "will return the same UUID associated with the current book" do
    uuid = StoryTeller.uuid

    expect(uuid).to eq(StoryTeller.uuid)
    StoryTeller.clear!
    expect(uuid).to_not eq(StoryTeller.uuid)
    expect(StoryTeller.uuid).to_not eq(nil)
  end
end