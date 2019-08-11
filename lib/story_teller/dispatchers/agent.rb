require "socket"

module StoryTeller::Dispatchers
  class Agent
    class SocketPathNotDefined < StandardError; end

    def initialize(config)
      @path = config[:path]
      if @path.nil?
        raise SocketPathNotDefined
      end
      @path.freeze
    end

    ## This method is used in a multi threaded
    # environment. For this reason, it can only read from
    # frozen variables and inputs fed into this method.
    #
    # The method also send data through the socket
    # without blocking the thread. This means we don't
    # deal with the return value.
    #
    # If any error happens here, we just log to stderr
    # and move on.
    def submit(data)
      socket = ::UNIXSocket.new(@path)
      socket.sendmsg_nonblock(data, 0)
      socket.close
    rescue StandardError => e
      log(e, data)
    end

    private

    def log(error, data)
      logger = StoryTeller::Config.logger
      logger.error error
      logger.error data
    end
  end
end
