# == Schema Information
#
# Table name: dummy_processors
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# This is dummy payment processor, not integrated with anything. It just sets appropriate values to #Payment
# if preconditions are met.
class DummyProcessor < ActiveRecord::Base
  has_one :payment, as: 'processor'

  def reserve(params)
    raise PreconditionsError, 'Payment state should be :created' unless payment.created?
    payment.update_attribute :state, :reserved
  end

  def settle
    payment.update_attribute :state, :settled
  end

  def release
    true
  end

  def refund
    true
  end

  def authorization_url(callback_url)
    callback_url
  end

  def as_json(options={})
    {}
  end
end
