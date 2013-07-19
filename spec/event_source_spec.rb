require 'event_source'

describe EventSource::EventSource do
  subject do
    EventSource::EventSource.new('http://google.com')
  end

  class CountingListener
    attr_accessor :call_count
    attr_reader :name

    def initialize(name)
      @name = name
      @call_count = 0
    end

    def call(message)
      self.call_count += 1
    end

    def to_proc
      public_method(:call)
    end
  end

  let(:listener) { CountingListener.new('Message Listener') }
  let(:named_listener) { CountingListener.new('Named Listener') }

  it "should call the on_message listener when an un-named event is received" do
    subject.on_message(&listener.to_proc)
    subject.data_received("id: 1\ndata: an un-named event\n\n")
    listener.call_count.should == 1
  end

  it "should call only the named listener when a named event is received" do
    subject.on_message(&listener.to_proc)
    subject.on 'named_event', &named_listener.to_proc

    subject.data_received("event: named_event\ndata: a named event\n\n")

    listener.call_count.should == 0
    named_listener.call_count.should == 1
  end

  it "should support partial event data" do
    subject.on_message(&listener.to_proc)

    subject.data_received("id: 1\ndata:")
    listener.call_count.should == 0

    subject.data_received(" an un-named event\n\n")
    listener.call_count.should == 1
  end
end

