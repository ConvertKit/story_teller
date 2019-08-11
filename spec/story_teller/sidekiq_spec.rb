require "story_teller"
require "story_teller/sidekiq"

describe StoryTeller::Sidekiq do
  around(:each) do |example|
    StoryTeller.clear!
    example.run
    StoryTeller.clear!
  end

  context "clearing the books" do
    it "clears the books before the middleware exits" do
      middleware = StoryTeller::Sidekiq.new
      3.times do
        middleware.call("worker", "job", "queue") do
          StoryTeller.tell(StoryTeller::Story.new(message: "test"))
        end
      end

      expect(StoryTeller.empty?).to eq(true)
    end
    
    it "clears the books even if an error is thrown" do
      middleware = StoryTeller::Sidekiq.new
      expect {
        middleware.call("worker", "job", "queue") do
          StoryTeller.tell(StoryTeller::Story.new(message: "test"))
          raise StandardError.new("Oops!")
        end
      }.to raise_error(StandardError)

      expect(StoryTeller.send(:book).dispatcher.events.size).to_not eq(0)
      expect(StoryTeller.empty?).to eq(true)
    end
  end
end
