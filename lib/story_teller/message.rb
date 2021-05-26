# frozen_string_literal: true

class StoryTeller::Message
  NIL_STRING = ""

  def initialize(template)
    if template.nil?
      @template = ""
      return
    end

    unless template.encoding.name == "UTF-8"
      @template = template.encode("UTF-8", invalid: :replace)
      return
    end

    @template = template
  end

  def render(attrs)
    attrs.each_pair do |k, v|
      attributes[k] = v.to_s
    end

    template % attributes
  rescue StandardError => e
    e.message
  end

  private

  attr_reader :template

  def attributes
    @attributes ||= Hash.new do
      NIL_STRING
    end
  end
end
