require 'net/http'

module EventSource
  module ReadyState
    CONNECTING = 0
    OPEN = 1
    CLOSED = 2
  end

  class Http
    def initialize(uri)
      @uri = uri
      @last_event_id = nil
      @ready_state = ReadyState::CLOSED
    end

    attr_accessor :last_event_id
    attr_reader :ready_state

    def listen(listener)
      self.ready_state = ReadyState::CONNECTING


      begin
        make_request do |response|
          self.ready_state = ReadyState::OPEN

          response.read_body do |data|
            listener.data_received(data)
          end
        end
      rescue IOError
        # handle manually closed case
        raise unless ready_state == ReadyState::CLOSED
      end
    end

    def finish
      return unless session
      self.ready_state = ReadyState::CLOSED
      session.finish
    end

    private

    attr_writer :ready_state
    attr_reader :uri
    attr_accessor :session

    def make_request
      create_session.start do |http|
        self.session = http
        http.request(create_request) do |response|
          yield response
        end
      end
    end

    def create_session
      Net::HTTP.new(uri.host, uri.port).tap do |http|
        if http.use_ssl = (uri.scheme == 'https')
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
      end
    end

    def create_request
      Net::HTTP::Get.new(uri.path).tap do |request|
        request['Accept'] = 'text/event-stream'
        request['Cache-Control'] = 'no-cache'
        request['Last-Event-Id'] = last_event_id if last_event_id
      end
    end
  end
end

