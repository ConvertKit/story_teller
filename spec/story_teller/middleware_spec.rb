require "story_teller/middleware"

context StoryTeller::Middleware do
  class ErrorApp
    def call(*)
      StoryTeller.tell(StoryTeller::Story.new(message: "test"))
      raise StandardError.new("Oops!")
    end
  end

  class NoStoryApp
    def call(*); end
  end

  class StoryApp
    def call(*)
      StoryTeller.tell(StoryTeller::Story.new(message: "test"))
    end
  end

  around(:each) do |example|
    StoryTeller.clear!
    StoryTeller.configure!({
      dispatcher: {
        type: :test
      }
    })
    example.run
    StoryTeller.clear!
  end

  describe "clearing the books" do
    it "clears the books even when an error occurs the middleware exits" do
      middleware = StoryTeller::Middleware.new(ErrorApp.new)
      expect {
        middleware.call({})
      }.to raise_error(StandardError)
      expect(StoryTeller.empty?).to eq(true)
    end

    it "clears the books before the middleware exits" do
      middleware = StoryTeller::Middleware.new(StoryApp.new)
      3.times do
        expect(StoryTeller.empty?).to eq(true)
        middleware.call({})
        expect(StoryTeller.empty?).to eq(true)
      end
    end
  end
end
