require "story_teller"

context StoryTeller::Book do
  let(:dispatcher) { StoryTeller::Dispatchers[:test].new }
  let(:book) { StoryTeller::Book.new(dispatcher: dispatcher) }

  context "#chapter" do
    it "finishes the chapter even with early return in the code" do
      value = "sadjlsj"
      -> {
        book.chapter title: "test", subtitle: 1234 do
          return value
        end
      }.call

      expect(book.current_chapter.title).to eq(StoryTeller::Book::UUID_CHAPTER_TITLE)
    end
  end

  context "#tell" do
    it "is a void method" do
      expect(book.tell("yolo")).to eq(nil)
      expect(book.tell("Danica\u{1f601}".force_encoding("US-ASCII"))).to eq(nil)
    end

    it "merges chapter into data" do
      id = "1234"
      title = "Test"
      message = "Yolo!"
      params = {
        foo: "bar",
        ahem: 1234
      }

      book.chapter title: title, subtitle: id do
        book.tell(**params, message: message)
      end

      event = JSON.parse(book.dispatcher.events.last)

      expect(event["data"].empty?).to eq(false)
      expect(event["data"].key?(title)).to eq(true)
      expect(event["data"][title]).to eq(id)
      expect(event["message"]).to eq(message)

      params.keys.each do |key|
        expect(event["data"][key.to_s]).to eq(params[key])
      end
    end

    it "gracefully handle a story with bad encoding" do
      id = "1234"
      title = "Test"
      message = "Yolo!"
      params = {
        foo: "Danica\u{1f601}".force_encoding("US-ASCII"),
        ahem: 1234
      }

      expect do
        book.chapter title: title, subtitle: id do
          book.tell(**params, message: message)
        end
      end.to_not raise_error
    end
  end

  it "should not keep a reference of a chapter when it's done" do
    expect(book.empty?).to eq(true)

    book.chapter(title: "test", subtitle: 123)

    expect(book.current_chapter.title).to eq(StoryTeller::Book::UUID_CHAPTER_TITLE)
  end

  it "should keep a reference of a chapter as long as it's used" do
    expect(book.empty?).to eq(true)

    book.chapter(title: "test", subtitle: 123) do
      expect(book.current_chapter.title).to eq("test")
      expect(book.empty?).to eq(false)
    end

    expect(book.current_chapter.title).to eq(StoryTeller::Book::UUID_CHAPTER_TITLE)
  end

  it "will keep the first chapter part of the stack as long as the child are not finished" do
    book.chapter(title: "test", subtitle: 123) do
      expect(book.current_chapter.title).to eq("test")
      book.chapter(title: "child", subtitle: 514) do
        expect(book.current_chapter.title).to eq("child")
      end
      expect(book.current_chapter.title).to eq("test")
    end
  end

  it "should dispatch all events processed" do
    size = 3
    book.chapter(title: "test", subtitle: 123) do
      size.times do
        book.tell StoryTeller::Story.new(message: "test")
      end
    end

    expect(book.dispatcher.events.size).to eq(size)
  end

  it "should always have a UUID chapter" do
    expect(book.current_chapter.title).to eq("UUID")
  end

  it "should tell a story to the current chapter" do
    story = StoryTeller::Story.new(message: "test")
    name = "child"
    id = "514"

    book.chapter(title: "test", subtitle: 123) do
      book.chapter(title: name, subtitle: id) do
        book.tell(story)
      end
    end

    event = JSON.parse(book.dispatcher.events.first)

    expect(book.dispatcher.events.size).to eq(1)
    expect(event["data"][name]).to eq(id)
  end

  it "should create a global chapter if there are no chapter present on the stack" do
    expect(book.empty?).to eq(true)

    story = StoryTeller::Story.new(message: "test")
    book.tell story

    expect(book.empty?).to eq(false)
  end

  it "will add chapter info to error story" do
    chapter = "Chapter A"
    expect {
      book.chapter(title: chapter, subtitle: 123) do
        raise StandardError
      end
    }.to raise_error(StandardError)

    event = JSON.parse(book.dispatcher.events.last)

    expect(event["severity"]).to eq(StoryTeller::Story::ERROR_LEVEL)
  end
end
