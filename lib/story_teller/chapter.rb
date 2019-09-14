class StoryTeller::Chapter
  attr_reader :title, :subtitle

  def initialize(title:, subtitle: nil, tracer: nil)
    @title = title
    @subtitle = Identifier.new(subtitle).value
    @tracer = tracer
    @attributes = {}
  end

  def run!(&block)
    start_time = Time.now.strftime("%s%9N")
    returned_value = nil
    returned_value = if @tracer.present?
                       @tracer.trace(self, block)
                     else
                       block.call(self)
                     end
    end_time = Time.now.strftime("%s%9N")
  rescue StandardError => error
    tell(StoryTeller::Error.new(error))
    raise error
  ensure
    tell(StoryTeller::Timing.new(elapsed: end_time - start_time))
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
