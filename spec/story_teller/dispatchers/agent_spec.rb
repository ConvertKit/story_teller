require "ostruct"
require "story_teller"
require "story_teller/dispatchers/agent"

RSpec.describe StoryTeller::Dispatchers::Agent do
  let(:path) { "/tmp/story_teller_spec#{SecureRandom.hex(3)}" }
  let(:config) do
    {
      dispatcher: {
        path: path
      }
    }
  end

  before(:each) do
    StoryTeller.configure!(config)
  end

  it "raises if the path is nil" do
    expect do
      dispatcher = StoryTeller::Dispatchers::Agent.new(config)
    end.to raise_error(StoryTeller::Dispatchers::Agent::SocketPathNotDefined)
  end

  it "doesn't raise if the connection to the socket can't be made" do
    config[:dispatcher][:path] = "wrong_path"
    StoryTeller.configure!(logger: Logger.new("/dev/null"))

    dispatcher = StoryTeller::Dispatchers::Agent.new(config[:dispatcher])

    expect do
      payload = { test: "hello" }.to_json.to_s
      dispatcher.submit(payload)
    end.to_not raise_error
  end

  it "logs the payload if can't connect to socket" do
    config[:dispatcher][:path] = "wrong_path"
    StoryTeller.configure!(logger: Logger.new("/dev/null"))
    dispatcher = StoryTeller::Dispatchers::Agent.new(config[:dispatcher])
    allow(dispatcher).to receive(:log)
    payload = { test: "hello" }.to_json.to_s

    result = dispatcher.submit(payload)

    expect(dispatcher).to have_received(:log)
  end

  it "sends data through the socket" do
    payload = { test: "hello" }.to_json.to_s

    thread = Thread.new do
      dispatcher = StoryTeller::Dispatchers::Agent.new(config[:dispatcher].dup)
      dispatcher.submit(payload)
    end

    server = UNIXServer.new(path)
    socket = server.accept
    thread.join

    expect(socket.recvmsg).to include(payload)

    socket.close
    File.delete(path)
  end
end
