module EventSource
  class Message
    def self.from_string(message_string)
      self.new.tap do |message|
        message_string.split("\n").each do |line|
          field, value = line.chomp.split(':', 2).map(&:strip)

          case field
          when 'id' then message.id = value
          when 'data' then message.add_data(value)
          when 'event' then message.event = value
          end
        end
      end
    end

    attr_accessor :id
    attr_accessor :event

    attr_reader :data
    attr_reader :retry

    def add_data(data)
      self.data = [self.data, data].compact.join("\n")
    end

    private

    attr_writer :data
  end
end

