# == Schema Information
#
# Table name: payments
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  event_id       :integer
#  amount         :decimal(, )
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  processor_id   :integer
#  processor_type :string(255)
#  state_cd       :integer          default(0)
#  tickets_count  :integer          default(1)
#
# Indexes
#
#  index_payments_on_event_id                         (event_id)
#  index_payments_on_processor_id_and_processor_type  (processor_id,processor_type)
#  index_payments_on_user_id                          (user_id)
#

require 'spec_helper'

describe Payment do
  before do
    @payment = create :payment
    subject { @payment }
  end

  it "should have valid factory" do
    @payment.should be_valid
  end

  it { should have_one(:band) }
  it { should have_one(:venue) }

  describe "validates that" do
    describe ":tickets_count" do
      it "is present" do
        should validate_presence_of :tickets_count
      end
      it "is integer number" do
        should validate_numericality_of(:tickets_count).only_integer
      end
      it "is positive" do
        @payment.tickets_count = -5
        @payment.save.should be_false
      end
    end
    it ":user_id, :event_id and :state are present" do
      should validate_presence_of :user_id
      should validate_presence_of :event_id
      should validate_presence_of :state
    end
    describe ":processor_type" do
      it "is present" do
        should validate_presence_of :processor_type
      end
      it "is in %w(AmazonProcessor DummyProcessor)" do
        @payment.processor_type = "Event"
        @payment.save.should be_false
        @payment.processor_type = "AmazonProcessor"
        @payment.save.should be_true
        @payment.processor_type = "DummyProcessor"
        @payment.save.should be_true
      end
    end
  end

  it "belongs to user" do
    should belong_to :user
  end
  it "belongs to event" do
    should belong_to :event
  end
  it "belongs to payment processor" do
    should belong_to :processor
  end

  it "should accept nested attributes for processor data" do
    should accept_nested_attributes_for :processor
  end

  it "should allow to create more than one payment with same 'user_id' and 'event_id'" do
    not_fail_to_save = create :payment
    not_fail_to_save.event_id = @payment.event_id
    not_fail_to_save.user_id = @payment.user_id
    not_fail_to_save.save.should be_true
  end

  it "removes associated payment processor when removed" do
    @processor = @payment.processor
    @payment.destroy
    @processor.class.where(id: @processor.id).count.should == 0
  end

  describe "'prepare_processor' method" do
    before :each do
      @payment = build :payment
    end
    context "when processor is not set" do
      before :each do
        @payment.processor = nil
        @payment.processor_type = "DummyProcessor"
        @payment.prepare_processor
        @payment.save
      end
      it "should add processor of given type" do
        @payment.processor.class.should eq(DummyProcessor)
      end
      it "saves new payment processor correctly" do
        pp = DummyProcessor.find(@payment.processor.id)
        pp.should eq(@payment.processor)
        pp.payment.should eq(@payment)
      end
    end
    context "when 'processor' is already set" do
      it "should do nothing" do
        lambda { @payment.prepare_processor }.should_not change(@payment, :updated_at)
      end
    end
    it "runs on payment creation" do
      @payment.should_receive(:prepare_processor)
      @payment.save
    end
  end

  it "should set payment amount as tickets_count * event.price" do
    @payment = create :payment, tickets_count: 10
    @payment.amount.should == 10 * @payment.event.price
  end

  describe "ticket availability validation" do
    it "should check tickets count" do
      @event = create :event, min_tickets: 2, max_tickets: 3
      create :payment, event: @event, tickets_count: 2
      @payment = build :payment, event: @event, tickets_count: 10
      @payment.save.should be_false
    end
    context "when event is raising" do
      before :each do
        @event = create :event, min_tickets: 100, max_tickets: 150
        @payment = build :payment, event: @event, tickets_count: 10
      end
      it "should validate that current time is lte event.raising_end" do
        @event.update_attribute :raising_end, Date.yesterday
        @payment.save.should be_false
      end
    end
    context "when event is planned" do
      before :each do
        @event = create :event, min_tickets: 2, max_tickets: 150
        create :reserved_payment, event: @event, tickets_count: 5
        @event = Event.find(@event.id)
        @payment = build :payment, event: @event, tickets_count: 10
      end
      it "should validate that current time is lte event.date" do
        @event.update_attribute :date, Date.yesterday
        @payment.save.should be_false
      end
    end
  end

  describe ":destroy method" do
    context "when payment is" do
      context "'created'" do
        before :each do
          @payment = create :payment, state: 'created'
        end
        it "should destroy payment" do
          @payment.destroy
          @payment.destroyed?.should be_true
        end
        it "should return true" do
          @payment.destroy.should be_true
        end
      end
      context "'reserved'" do
        before :each do
          @payment = create :payment, state: 'reserved'
        end
        it "should destroy payment" do
          @payment.destroy
          @payment.destroyed?.should be_true
        end
        it "should call :release on processor" do
          @payment.processor.should_receive(:release).and_return(true)
          @payment.destroy
        end
      end
      context "'settled'" do
        context "when event is planned" do
          before :each do
            @event = create :event, state: 'planned'
            @payment = create :payment, state: 'settled', event: @event
          end
          it "should destroy payment" do
            @payment.destroy
            @payment.destroyed?.should be_true
          end
          it "should call :refund on processor" do
            @payment.processor.should_receive(:refund).and_return(true)
            @payment.destroy
          end
        end
        context "when event is archived" do
          before :each do
            @event = create :event, state: 'archived'
            @payment = create :payment, state: 'settled', event: @event
          end
          it "should raise error" do
            lambda { @payment.destroy }.should(
                raise_error OperationForbiddenError, "Destruction of payments for archived events is forbidden"
            )
          end
        end
      end
    end
  end

  describe ":as_json method" do
    subject { @payment.as_json }
    it { should be_a(Hash) }
    it do
      should == {
          'id' => @payment.id,
          'user_id' => @payment.user_id,
          'event_id' => @payment.event_id,
          'tickets_count' => @payment.tickets_count,
          'amount' => @payment.amount,
          'processor_type' => @payment.processor_type,
          'state' => @payment.state,
          'created_at' => @payment.created_at,
          'updated_at' => @payment.updated_at
      }
    end
  end
end
