module EventSource
  class EventSource
    def initialize(uri, connection_provider = Http)
      @message_listeners = [ ]
      @named_message_listeners = { }

      @buffer = ""

      @connection = connection_provider.new(uri)
    end

    def listen
      connection.listen(self)
    end

    def on_message(&listener)
      self.message_listeners << listener
    end

    def on(event_name, &listener)
      (self.named_message_listeners[event_name] ||= [ ]) << listener
    end

    def data_received(data)
      self.buffer += data
      while message = extract_message
        handle_message(message)
      end
    end

    def finish
      connection.finish
    end

    protected

    attr_accessor :message_listeners
    attr_accessor :named_message_listeners
    attr_accessor :buffer

    private

    attr_reader :connection

    def extract_message
      return unless message_index = buffer.index("\n\n")
      Message.from_string(buffer.slice!(0..message_index))
    end

    def handle_message(message)
      connection.last_event_id = message.id if message.id
      listeners_for(message).each { |listener| listener.call(message) }
    end

    def listeners_for(message)
      if message.event
        named_message_listeners.fetch(message.event, [ ])
      else
        message_listeners
      end
    end
  end
end

