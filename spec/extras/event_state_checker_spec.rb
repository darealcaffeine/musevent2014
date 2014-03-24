require "spec_helper"

describe EventStateChecker do
  let(:checker) { EventStateChecker.new }
  before do
    @normal_event = create :event
  end
  describe ":archive_passed" do
    subject { checker.archive_passed }
    before do
      @events_count = 10
    end
    before :each do
      @expired_event_ids = []
      @events_count.times do
        @expired_event_ids << create(:expired_event, date: DateTime.yesterday, state: 'planned').id
      end
    end
    it "should not affect normal event" do
      subject
      Event.find(@normal_event.id).should == @normal_event
    end
    it "should handle all expired events" do
      subject.should == @events_count
    end
    it "should mark all expired events as archived" do
      subject
      @expired_event_ids.each do |id|
        Event.find(id).state.should == 'archived'
      end
    end
  end

  describe ":archive_failed_raising" do
    subject { checker.archive_failed_raising }
    before do
      @events_count = 10
    end
    before :each do
      @expired_event_ids = []
      @events_count.times do
        @expired_event_ids << create(
            :expired_event, raising_end: DateTime.yesterday, min_tickets: 10500, state: 'raising'
        ).id
      end
    end
    it "should not affect normal event" do
      subject
      Event.find(@normal_event.id).should == @normal_event
    end
    it "should handle all expired events" do
      subject.should == @events_count
    end
    it "should mark all expired events as archived" do
      subject
      @expired_event_ids.each do |id|
        Event.find(id).state.should == 'archived'
      end
    end
  end

end