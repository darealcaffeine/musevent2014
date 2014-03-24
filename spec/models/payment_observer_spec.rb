require 'spec_helper'

describe PaymentObserver do
  before :each do
    @payment = create :reserved_payment
    @observer = PaymentObserver.instance
  end
  describe "'check_event_state' method" do
    it "should exist" do
      lambda { @observer.check_event_state @payment }.should_not raise_error(NoMethodError)
    end
    it "should require one argument" do
      lambda { @observer.check_event_state }.should raise_error(ArgumentError)
      lambda { @observer.check_event_state @payment }.should_not raise_error(ArgumentError)
    end
    context "when not enough funds raised" do
      before :each do
        @payment.event.update_attribute :min_tickets, 100500
      end
      it "should do nothing" do
        lambda { @observer.check_event_state @payment }.should_not change { @payment.event.state }
      end
    end
    context "when enough funds raised" do
      before :each do
        @payment.event.update_attribute :min_tickets, 1
      end
      context "and event is in 'raising' state" do
        before :each do
          @payment.event.state = :raising
        end
        it "should change event state to 'planned'" do
          @observer.check_event_state @payment
          @payment.event.planned?.should be_true
        end
      end
      context "and event is not in 'raising' state" do
        before :each do
          @payment.event.state = :planned
        end
        it "should do nothing" do
          lambda { @observer.check_event_state @payment }.should_not change { @payment.event.state }
        end
      end
    end
    describe "multi-ticket payment handling" do
      before :each do
        @event = create :event, min_tickets: 100, max_tickets: 200
        @payment = create :payment, tickets_count: 10, event: @event, state: 'reserved'
      end
      it "should work" do
        @event.update_attribute :min_tickets, 5

        @observer.check_event_state @payment

        @event.planned?.should be_true
      end
    end
  end
  describe "'after_save' method" do
    it "should call 'check_event_state' method" do
      @observer.should_receive(:check_event_state).with(@payment)
      @observer.after_save @payment
    end
    it "should call ''refresh_event_fields' method'" do
      @observer.should_receive(:refresh_event_fields).with(@payment)
      @observer.after_save @payment
    end
  end

  describe "'refresh_event_fields' method" do
  end
end
