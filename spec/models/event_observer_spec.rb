require 'spec_helper'

describe EventObserver do
  before :each do
    @event = create :event
    @observer = EventObserver.instance
  end
  describe "'settle_reserved_payments' method" do
    before :each do
      @p1 = create :reserved_payment, event_id: @event.id
      @p2 = create :reserved_payment, event_id: @event.id
    end
    it "should exist" do
      lambda { @observer.settle_reserved_payments @event }.should_not raise_error(NoMethodError)
    end
    it "should require one argument" do
      lambda { @observer.settle_reserved_payments }.should raise_error(ArgumentError)
      lambda { @observer.settle_reserved_payments @event }.should_not raise_error(ArgumentError)
    end
    it "should settle reserved payments for the event" do
      @observer.settle_reserved_payments @event
      Payment.find(@p1.id).settled?.should be_true
      Payment.find(@p2.id).settled?.should be_true
    end
  end

  describe "'after_save' method" do
    context "state changed to 'planned'" do
      before do
        @event.state = :planned
      end
      it "should call 'settle_reserved_payments' method" do
        @observer.should_receive(:settle_reserved_payments).with(@event)
        @observer.after_save @event
      end
      it "should call :notify_raising_success method" do
        @observer.should_receive(:notify_raising_success).with(@event)
        @observer.after_save @event
      end
    end
    context "state changed from 'raising' to 'archived'" do
      before do
        @event.state = :archived
      end
      it "should call :notify_raising_failure method" do
        @observer.should_receive(:notify_raising_failure).with(@event)
        @observer.after_save @event
      end
    end
    context "state changed from 'planned' to 'archived'" do
      before do
        @event.update_attribute :state, :planned
        @event.state = :archived
      end
      it "should not call :notify_raising_failure method" do
        @observer.should_not_receive(:notify_raising_failure).with(@event)
        @observer.after_save @event
      end
    end
  end

  describe "notification" do
    before do
      @event = create :event
      users = []
      10.times { users << create(:user) }
      users.each { |user| create :payment, state: 'reserved', event: @event, user: user }
      @user = users.first
      create :payment, state: 'reserved', event: @event, user: @user # so @user has 2 payments

      ActionMailer::Base.delivery_method = :test
      ActionMailer::Base.perform_deliveries = true

      @mail = Mail.new
      @mail.should_receive(:deliver).any_number_of_times.and_return(true)
    end
    describe ":notify_raising_success method" do
      before do
        ActionMailer::Base.deliveries = []
        @observer.notify_raising_success @event
      end
      describe "delivered emails" do
        subject { ActionMailer::Base.deliveries }
        it { subject.length.should == 10 }
      end
      it "should use proper mailer" do
        EventMailer.should_receive(:notify_raising_success).exactly(10).and_return(@mail)
        @observer.notify_raising_success @event
      end
    end
    describe ":notify_raising_failure method" do
      before do
        ActionMailer::Base.deliveries = []
        @observer.notify_raising_failure @event
      end
      describe "delivered emails" do
        subject { ActionMailer::Base.deliveries }
        it { subject.length.should == 10 }
      end
      it "should use proper mailer" do
        EventMailer.should_receive(:notify_raising_failure).exactly(10).and_return(@mail)
        @observer.notify_raising_failure @event
      end
    end
  end
end
