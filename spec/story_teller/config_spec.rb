context StoryTeller::Config do
  describe ".configure!" do
    it "can set the logger" do
      logger = Logger.new(STDOUT)
      StoryTeller::Config.configure!(logger: logger)

      expect(StoryTeller::Config.logger).to eq(logger)
    end

    it "sets a default logger" do
      StoryTeller::Config.configure!

      expect(StoryTeller::Config.logger).to_not eq(nil)
    end

    it "set the dispatcher configuration" do
      path = "/dev/null"
      StoryTeller.configure!(dispatcher: { path: path })

      expect(StoryTeller::Config.dispatcher[:path]).to eq(path)
    end

    it "converts string keys to symbol in dispatcher config" do
      path = "/dev/null"
      StoryTeller::Config.configure!(dispatcher: { "path" => path })

      expect(StoryTeller::Config.dispatcher[:path]).to eq(path)
    end

    it "defaults to the logger dispatcher" do
      StoryTeller::Config.configure!

      expect(StoryTeller::Config.dispatcher[:type]).to eq(:logger)
    end
  end
end
