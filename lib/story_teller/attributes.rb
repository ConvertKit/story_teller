require "forwardable"

module StoryTeller
  class Attributes
    extend Forwardable

    def_delegators :@data, :each_pair

    def initialize(hash)
      hash.each_pair do |key, value|
        data[convert(key)] = value
      end

      @message = StoryTeller::Message.new(data.delete(:message))
    end

    def message
      @message.render(data)
    end

    def valid?
      @message.valid?
    end

    def to_hash
      data
    end

    private

    def data
      @data ||= {}
    end

    def convert(key)
      key.is_a?(Symbol) ? key : key.to_sym
    end
  end
end
