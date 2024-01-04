# frozen_string_literal: true

module StoryTeller
  module Version
    MAJOR = 0
    MINOR = 0
    PATCH = 8
    BUILD = ""

    def self.to_s
      v = [
        MAJOR,
        MINOR,
        PATCH
      ]
      v << BUILD unless BUILD.strip.empty?
      v.compact.join(".")
    end
  end
end
