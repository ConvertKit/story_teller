# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "story_teller/version"

Gem::Specification.new do |s|
  s.name        = "story_teller"
  s.version     = StoryTeller::Version.to_s
  s.licenses    = ["MIT"]
  s.summary     = "Production logging for sane development"
  s.description = %s{
    StoryTeller is a logging framework to create meaningful logs
    that create a story through structured JSON to give insight as what
    is going on in your production deployments.
  }
  s.authors     = ["Pier-Olivier Thibault"]
  s.email       = "pier-olivier@convertkit.com"
  s.homepage    = "https://github.com/convertkit/story_teller"
  s.metadata    = { "source_code_uri" => "https://github.com/convertkit/story_teller" }

  s.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(agent|test|spec|features)/})
  end

  s.require_paths = ["lib"]
end
