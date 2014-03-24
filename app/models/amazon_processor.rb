# == Schema Information
#
# Table name: amazon_processors
#
#  id               :integer          not null, primary key
#  transaction_id   :string(255)      default("")
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  caller_reference :string(255)
#

# #AmazonProcessor class is used for processing payments through Amazon FPS.
# Current implementation uses Remit gem for it.
#
# Is connected to #Payment as #Payment.processor polymorphic association.
class AmazonProcessor < ActiveRecord::Base
  attr_accessible :payment
  has_one :payment, as: 'processor'

  # #reserve method is used to freeze funds on payment account, without actually charging them.
  #
  # This method calls #validate_reservation_response to make sure that it is being called by actual Amazon FPS
  # service as a callback.
  #
  # Also payment reservation requires that #payment.state should be :created.
  #
  # If params are valid FPS reservation response and preconditions are met, method performs funds reservation using
  # #Remit::Reserve request, saves generated #caller_reference and #transaction_id to database and updates
  # #payment.state to :reserved
  #
  # Known issue: on Amazon FPS reservation is valid for 7 days only.
  def reserve(params)
    AmazonProcessor.validate_reservation_response params
    raise PreconditionsError, 'Payment state should be :created' unless payment.created?
    r_amount = Remit::RequestTypes::Amount.new ({value: payment.amount, currency_code: 'USD'})
    caller_ref = new_caller_reference
    request = Remit::Reserve::Request.new ({
        recipient_token_id: recipient_token,
        sender_token_id: params[:tokenID],
        caller_reference: caller_ref,
        transaction_amount: r_amount,
        charge_fee_to: 'Caller'
    })

    response = remit.reserve(request)

    raise ApiInteractionError, response.errors.join('; ') unless response.errors.empty?

    update_attribute :transaction_id, response.reserve_result.transaction_id
    update_attribute :caller_reference, caller_ref
    payment.update_attribute :state, :reserved
  end

  # This method settles previously reserved payment (actually charges payment account).
  #
  # *Preconditions*: #transaction_id should be set and #payment.state should be :reserved.
  #
  # If preconditions are met, method settles payment using #Remit::Settle and updates #payment.state to :settled
  def settle
    raise PreconditionsError, 'Transaction id is required' if transaction_id.nil? or transaction_id.empty?
    raise PreconditionsError, "Payment should be reserved" unless payment.reserved?
    r_amount = Remit::RequestTypes::Amount.new ({value: payment.amount, currency_code: 'USD'})
    request = Remit::Settle::Request.new ({
        reserve_transaction_id: transaction_id,
        transaction_amount: r_amount
    })
    response = remit.settle request

    raise ApiInteractionError, response.errors.join('; ') unless response.errors.empty?

    payment.update_attribute :state, :settled
  end

  # This method is used when payment is destroyed and non-charged funds need to be released on payment account.
  def release
    request = Remit::Cancel::Request.new(transaction_id: transaction_id)
    response = remit.cancel request
    response.errors.empty?
  end

  # This method is used when payment is destroyed and charged funds need to be refunded to user.
  def refund
    request = Remit::Refund::Request.new(transaction_id: transaction_id, caller_reference: caller_reference)
    response = remit.refund request
    response.errors.empty?
  end

  def authorization_url(callback_url)
    remit.get_single_use_pipeline(
        caller_reference: new_caller_reference,
        transaction_amount: payment.amount,
        return_url: callback_url
    ).url
  end

  # This method always returns blank hash as we want to make sure that we never, even accidentally,render user's
  # private payment information.
  def as_json(options={})
    {}
  end

  private

  def remit
    # hardcode sandbox == true for now
    sandbox = true
    Remit::API.new(FPS_ACCESS_KEY, FPS_SECRET_KEY, sandbox)
  end

  def recipient_token
    request = Remit::InstallPaymentInstruction::Request.new(
        payment_instruction: "MyRole == 'Recipient' orSay 'Role does not match';",
        caller_reference: new_caller_reference,
        token_friendly_name: "Recipient Token",
        token_type: "Unrestricted"
    )
    remit.install_payment_instruction(request).install_payment_instruction_result.token_id
  end

  # This method validates that reservation call actually comes from Amazon FPS.
  def self.validate_reservation_response(hash)
    %w(status signature signatureVersion signatureMethod certificateUrl).each do |field|
      raise MalformedServiceResponseError, "'#{field}' is missing" unless hash[field.to_sym]
    end
    raise ApiInteractionError, hash[:errorMessage] if hash[:status] == 'NP'
    raise MalformedServiceResponseError, "'#{hash[:status]}' is unknown falue for 'status'" if hash[:status] != 'SC'

    raise MalformedServiceResponseError, "'tokenID' is missing" unless hash[:tokenID]
  end

  def new_caller_reference
    (0...8).map { 65.+(rand(25)).chr }.join
  end
end
