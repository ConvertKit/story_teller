class StoryTeller::Sidekiq
  def initialize; end

  def call(worker, job, queue)
    yield
  ensure
    StoryTeller.clear!
  end
end
