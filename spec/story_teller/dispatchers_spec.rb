require "story_teller/dispatchers"

context StoryTeller::Dispatchers do
  it "will raise if the dispatcher is not valid" do
    expect do
      StoryTeller::Dispatchers[:does_not_exist]
    end.to raise_error(StoryTeller::Dispatchers::UnknownDispatcherError)
  end

  it "returns a class of a supported agent" do
    expect(StoryTeller::Dispatchers[:agent].to_s).to eq("StoryTeller::Dispatchers::Agent")
    expect(StoryTeller::Dispatchers[:logger].to_s).to eq("StoryTeller::Dispatchers::Logger")
    expect(StoryTeller::Dispatchers[:test].to_s).to eq("StoryTeller::Dispatchers::Test")
  end
end
