class StoryTeller::Chapter
  attr_reader :title, :subtitle

  def initialize(title:, subtitle: nil)
    @title = title
    @subtitle = Identifier.new(subtitle).value
    @attributes = {}
  end

  def to_hash
    hash = @attributes.dup
    hash[@title.to_s.to_sym] = @subtitle

    hash
  end

  def [](key)
    @attributes[key.to_sym]
  end

  def []=(key, value)
    @attributes[key.to_sym] = value
  end

  def merge(hash)
    hash.each_pair do |key, value|
      @attributes[key.to_sym] = value
    end
  end

  class Identifier
    NIL_RESOURCE = "nil".freeze
    UNDEFINED_RESOURCE = "Undefined".freeze

    def initialize(object)
      @object = object
    end

    def value
      @value ||= begin
        case @object
        when NilClass
          NIL_RESOURCE
        when Integer, String
          return @object
        else
          compile(@object)
        end
      end
    end

    private

    def class_name_for(object)
      object.class.name || UNDEFINED_RESOURCE
    end

    def compile(object)
      if object.respond_to?(:id)
        return [
          class_name_for(object),
          object.id
        ].join("#")
      end

      object.to_s
    rescue StandardError => e
      e.class.name
    end
  end
end
