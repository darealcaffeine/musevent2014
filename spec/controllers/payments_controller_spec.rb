require 'spec_helper'

describe PaymentsController do
  before do
    @user = create :user
    sign_in @user
    bypass_rescue
  end
  before :each do
    @payment = create :payment, user: @user
  end
  describe "authorization_url method" do
    it "should take one argument" do
      lambda { controller.authorization_url }.should raise_error(ArgumentError)
    end
    it "should call processor's 'authorization_url' method with payment url" do
      @payment.processor.should_receive(:authorization_url).with(reserve_payment_url(@payment.id))
      controller.authorization_url @payment
    end
  end

  describe "create method" do
    before do
      @event = create :event
    end
    before :each do
      @params = {
          event_id: @event.id,
          payment: {
              processor_type: 'DummyProcessor',
              tickets_count: '10'
          }
      }
    end
    it "should create payment correctly" do
      payment = create :payment
      Payment.should_receive(:new, {event_id: @event.id,
                                    user_id: @user.id,
                                    tickets_count: @params[:payment][:tickets_count].to_i,
                                    processor_type: @params[:payment][:processor_type]
      }).and_return(payment)
      post :create, @params
    end
    it "should add payment" do
      lambda { post :create, @params }.should change { Payment.count }.by(1)
    end
    it "should add payment processor" do
      lambda { post :create, @params }.should change { DummyProcessor.count }.by(1)
    end
    it "should redirect to payment authorization url with 302" do
      @actual_payment = create :payment
      Payment.should_receive(:new).and_return @actual_payment
      @actual_payment.should_receive(:save!).and_return true
      post :create, @params
      response.should redirect_to(controller.authorization_url @actual_payment)
      response.code.to_i.should eq(302)
    end
    context "when payment is invalid" do
      before :each do
        @actual_payment = create :payment
        Payment.should_receive(:new).and_return @actual_payment
        @actual_payment.should_receive(:save!).and_raise(ActiveRecord::RecordNotSaved)
      end
      it "should render 'new' template" do
        post :create, @params
        response.should render_template('new')
      end
      it "should respond with '400' code" do
        post :create, @params
        response.code.to_i.should == 400
      end
    end
    context "when user is not allowed to create payments" do
      before do
        sign_in create(:guest)
      end
      it "should raise exception" do
        lambda { post :create, @params }.should raise_error(
                                                    PaymentsControllerError, "You are not allowed to create payments")
      end
      it "should not add payment" do
        begin
          lambda { post :create, @params }.should_not change { Payment.count }
        rescue
          1+1
        end
      end
    end
  end

  describe "reserve method" do
    before :each do
      @params = {id: @payment.id}
      t = Payment.includes(:processor, :event)
      Payment.should_receive(:includes).with(:processor, :event).and_return(t)
      t.should_receive(:find).with(@payment.id.to_s).and_return(@payment)
    end

    it "should call :reserve on payment processor" do
      @payment.processor.should_receive(:reserve).and_return(true)
      get :reserve, @params
    end
    it "should raise error if payment reservation failed" do
      @payment.processor.should_receive(:reserve).and_raise PaymentProcessingError.new('test')
      lambda { get :reserve, @params }.should(
          raise_error(PaymentsControllerError, "Unable to reserve funds on payment account, reason: 'test'. Please contact support.")
      )
    end

    context "when reservation is successful" do
      before :each do
        @payment.processor.should_receive(:reserve).and_return(true)
      end
    end
    it "should return HTTP 200" do
      get :reserve, @params
      response.should be_success
    end
    it "should render :reserve template" do
      get :reserve, @params
      response.should render_template("reserve")
    end

    context "when user is not allowed to reserve payment" do
      before do
        sign_in create(:user)
      end
      it "should raise exception" do
        lambda { get :reserve, @params }.should raise_error(CanCan::AccessDenied)
      end
      it "should not reserve payment" do
        st = @payment.state
        begin
          get :reserve, @params
        rescue CanCan::AccessDenied
          1+1
        end
        @payment.state.should == st
      end
    end
  end

  describe "show method" do
    before :each do
      @params = {id: @payment.id}
    end
    it "should assign payment" do
      get :show, @params
      assigns[:payment].should == @payment
    end
    it "should raise error if payment belongs to other user" do
      @other = create :payment
      lambda { get :show, {id: @other.id} }.should raise_error(CanCan::AccessDenied)
    end
  end

  describe "new method" do
    before :each do
      @event = create :event
    end
    it "assigns new payment as @payment" do
      get :new, {:event_id => @event.to_param}
      assigns[:payment].should be_new_record
    end
    it "assigns event as @event" do
      get :new, {:event_id => @event.to_param}
      assigns[:event].should eq(@event)
    end
    it "raises error when event does not exist" do
      lambda { get :new, {:event_id => 80085} }.should(
          raise_error(PaymentsControllerError, "Event #80085 does not exist, you can't create payment for it"))
    end
  end

  describe ":index method" do
    before do
      50.times do
        create :payment, user: @user
      end
    end
    before :each do
      @event = @payment.event
    end

    it "should load 25 payments" do
      get :index
      assigns[:payments].count.should == 25
    end
    it "should not load other users' payments" do
      @other = create :payment
      get :index
      assigns[:payments].should_not include(@other)
    end
  end

  describe ":destroy method" do
    before do
      @event = create :event
      @operation = lambda { delete :destroy, {id: @payment.id} }
    end

    context "when user is allowed to remove event" do
      before :each do
        @payment = create :payment, event: @event, user: @user
      end
      it "should change event.tickets_sold by :tickets_count" do
        @operation.should change(@event, :tickets_sold).by(-@payment.tickets_count)
      end
      it "should redirect to payments list" do
        @operation.call
        response.should redirect_to(action: 'index')
      end
      it "should set flash message" do
        @operation.call
        flash[:success].should == "Your payment was canceled"
      end
    end

    context "when payment belongs to another user" do
      before :each do
        @payment = create :payment, event: @event
      end
      it "should raise error" do
        @operation.should raise_error(CanCan::AccessDenied)
      end
    end

    context "when payment is already charged" do
      before :each do
        @event = create :event, state: 'archived'
        @payment = create :payment, event: @event, user: @user, state: 'settled'
      end
      it "should raise error" do
        @operation.should(
            raise_error PaymentsControllerError, "This payment is already charged, you can't cancel it"
        )
      end
    end
  end
end