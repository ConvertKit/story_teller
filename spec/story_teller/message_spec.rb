describe StoryTeller::Message do
  context "#initialize" do
    it "automatically converts template to UTF-8" do
      template = "Danica\u{1f601}".force_encoding("US-ASCII")

      message = StoryTeller::Message.new(template)
      expect(message.send(:template).encoding.name).to eq("UTF-8")
    end
  end

  context "#render" do
    it "renders a message" do
      content = "Hello %{foo}"
      attributes = { foo: "bar" }

      message = StoryTeller::Message.new(content)
      expect(message.render(attributes)).to eq(content % attributes)
    end

    it "renders nil value from attributes" do
      content = "Hello %{foo}"
      attributes = { foo: nil }

      message = StoryTeller::Message.new(content)
      expect(message.render(attributes)).to eq(content % {foo: ""})
    end

    it "renders even if the attribute is missing" do
      content = "Hello %{foo}"
      attributes = {}

      message = StoryTeller::Message.new(content)
      expect(message.render(attributes)).to eq(content % {foo: ""})
    end

    it "renders even if interpolation raises an exception" do
      content = "Hello %{<Invalid Syntax>}"
      attributes = {}

      message = StoryTeller::Message.new(content)
      expect do
        expect(message.render(attributes)).to_not eq(nil)
      end.to_not raise_error
    end
  end
end
