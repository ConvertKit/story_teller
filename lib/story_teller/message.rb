class StoryTeller::Message
  NIL_STRING = "".freeze

  def initialize(template)
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

  def valid?
    @template.present?
  end

  private

  attr_reader :template

  def attributes
    @attributes ||= Hash.new do
      NIL_STRING
    end
  end
end
