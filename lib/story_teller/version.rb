# frozen_string_literal: true

module StoryTeller
  module Version
    MAJOR = 0
    MINOR = 0
    TINY = 3
    BUILD = "alpha"

    def self.to_s
      [
        MAJOR,
        MINOR,
        TINY,
        BUILD
      ].compact.join(".")
    end
  end
end
