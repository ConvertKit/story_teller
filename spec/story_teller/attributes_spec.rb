context StoryTeller::Attributes do
  describe "#initialize" do
    it "convert all keys to symbols" do
      attributes = StoryTeller::Attributes.new("hello" => "world", something: true)

      attributes.each_pair do |k, _|
        expect(k).to be_a(Symbol)
      end
    end
  end

  describe "#to_hash" do
    it "doesn't include the message" do
      attributes = StoryTeller::Attributes.new(
        "hello" => "world",
        something: 123,
        message: "<Something %{something}> is <Cooking %{cooking}>."
      )

      attributes.each_pair do |k, _|
        expect(k).to_not eq(:message)
      end
    end
  end

  describe "#message" do
    it "renders the message with the current attribute" do
      attributes = StoryTeller::Attributes.new(
        "hello" => "world",
        something: 123,
        message: "<Something %{something}> is <Cooking %{cooking}>."
      )

      expect(attributes.message).to eq("<Something 123> is <Cooking >.")
    end
  end
end
