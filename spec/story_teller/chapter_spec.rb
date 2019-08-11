context StoryTeller::Chapter do
  let(:chapter) { StoryTeller::Chapter.new(title: "test", subtitle: 123) }

  describe "#merge" do
    it "merges an hash into the attributes of the receiving chapter" do
      key = "something::weird"
      value = 19_213
      chapter.merge(key => value)

      expect(chapter[key]).to eq(value)
    end

    it "overrides previously set attributes" do
      key = "Account"
      value = "213"
      chapter[key] = value

      expect(chapter[key]).to eq(value)

      chapter.merge(key => 1)

      expect(chapter[key]).to_not eq(value)
    end
  end

  describe "#to_hash" do
    it "includes uuid" do
      uuid = SecureRandom.uuid
      chapter.merge(uuid: uuid)
      expect(chapter.to_hash[:uuid]).to eq(uuid)
    end

    it "includes the name in each story" do
      expect(chapter.to_hash.key?(:test)).to eq(true)
    end

    it "includes the id of a value if it can in each story" do
      name = "test"
      id = 123_455
      value = Struct.new(:id).new(id)
      chapter = StoryTeller::Chapter.new(title: name, subtitle: value)

      expect(chapter.to_hash[name.to_sym]).to end_with(id.to_s)
    end
  end

  describe StoryTeller::Chapter::Identifier do
    it "handles nil value" do
      identifier = StoryTeller::Chapter::Identifier.new(nil)

      expect(identifier.value).to eq(StoryTeller::Chapter::Identifier::NIL_RESOURCE)
    end

    it "doesn't transform an integer" do
      value = 12_345
      identifier = StoryTeller::Chapter::Identifier.new(value)

      expect(identifier.value).to eq(value)
    end

    it "doesn't transform a string" do
      value = "A Resource"
      identifier = StoryTeller::Chapter::Identifier.new(value)

      expect(identifier.value).to eq(value)
    end

    it "includes name of a class if available" do
      value = Struct.new(:id, :class).new(1234, Object)
      identifier = StoryTeller::Chapter::Identifier.new(value)

      expect(identifier.value).to start_with(value.class.name)
      expect(identifier.value).to ending_with(value.id.to_s)
    end

    it "uses object.to_s as an identifier if the object doesn't respond to id" do
      value = Struct.new(:stuff).new(1234)
      identifier = StoryTeller::Chapter::Identifier.new(value)

      expect(identifier.value).to eq(value.to_s)
    end

    it "uses a id and class representation if it can respond to id" do
      value = Struct.new(:id).new(1234)
      identifier = StoryTeller::Chapter::Identifier.new(value)

      expect(identifier.value).to start_with(StoryTeller::Chapter::Identifier::UNDEFINED_RESOURCE)
      expect(identifier.value).to ending_with(value.id.to_s)
    end
  end
end
