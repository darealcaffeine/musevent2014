class PaymentsController < ApplicationController
  before_filter :authenticate_user!

  def create
    authorize! :create, Payment
    @event = Event.find(params[:event_id])
    @payment = Payment.new params[:payment].merge({event_id: @event.id, user_id: current_user.id})
    @payment.save!
    @authorization_url = authorization_url(@payment)
    respond_to do |format|
      format.html { redirect_to @authorization_url }
      format.json { render 'show' }
    end
  rescue CanCan::AccessDenied
    raise PaymentsControllerError, "You are not allowed to create payments"
  rescue ActiveRecord::RecordNotSaved
    render action: :new, status: 400
  end

  def reserve
    @payment = Payment.includes(:processor, :event).find(params[:id])
    authorize! :reserve, @payment
    @payment.processor.reserve params
    respond_to do |format|
      format.html
      format.json { render 'show' }
    end
  rescue PaymentProcessingError => processing_error
    raise PaymentsControllerError,
          "Unable to reserve funds on payment account, reason: '#{processing_error.message}'. Please contact support."
  end

  def show
    @payment = Payment.find(params[:id])
    authorize! :show, @payment
  end

  def new
    @payment = Payment.new
    @event = Event.find(params[:event_id])
  rescue ActiveRecord::RecordNotFound
    raise PaymentsControllerError, "Event ##{params[:event_id]} does not exist, you can't create payment for it"
  end

  def index
    @payments = Payment.joins(:event).where(user_id: current_user.id).page(params[:page]).order('updated_at DESC')
  end

  def destroy
    @payment = Payment.find(params[:id])
    authorize! :destroy, @payment
    @payment.destroy
    flash[:success] = "Your payment was canceled"
    respond_to do |format|
      format.html { redirect_to payments_path }
      format.json { render json: {result: 'success'} }
    end
  rescue OperationForbiddenError
    raise PaymentsControllerError, "This payment is already charged, you can't cancel it"
  rescue PaymentProcessingError
    raise PaymentsControllerError, "Payment cancellation failed. Please contact support"
  end

  def authorization_url(payment)
    payment.processor.authorization_url reserve_payment_url(payment.id)
  end
end
