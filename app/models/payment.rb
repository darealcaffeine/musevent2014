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

class Payment < ActiveRecord::Base
  delegate :title, :state, to: :event, prefix: true
  delegate :band_id, :venue_id, to: :event, prefix: false

  def self.processor_types
    %w(DummyProcessor AmazonProcessor)
  end

  def self.named_processor_types
    {
        'DummyProcessor' => 'Test Dummy',
        'AmazonProcessor' => 'Amazon'
    }
  end

  belongs_to :user
  belongs_to :event
  belongs_to :processor, polymorphic: true, dependent: :destroy
  has_one :band, through: :event
  has_one :venue, through: :event

  as_enum :state, %w(created reserved settled)

  attr_accessible :amount, :event_id, :state, :user_id, :processor_id, :processor_type, :tickets_count

  validates_presence_of :event_id, :user_id, :state, :processor_type, :tickets_count
  validates_inclusion_of :processor_type, in: processor_types
  validates_numericality_of :tickets_count, only_integer: true, greater_than: 0
  validate :event_has_enough_tickets
  validate :event_available_for_payments, unless: 'event.nil?'

  accepts_nested_attributes_for :processor

  before_save :prepare_processor
  before_create :compute_amount

  def prepare_processor
    return unless processor.nil?
    pp = processor_type.constantize.new
    pp.save
    self.processor = pp
  end

  def destroy
    case state
      when 'reserved'
        processor.release
      when 'settled'
        raise OperationForbiddenError,
              "Destruction of payments for archived events is forbidden" if event.state == 'archived'
        processor.refund
    end
    super
  end

  def as_json(options={})
    defaults = {
        only: [:created_at, :event_id, :id, :processor_type, :tickets_count, :updated_at, :user_id, :amount],
        methods: 'state'
    }
    super defaults.merge!(options)
  end

  private

  def compute_amount
    self.amount = event.price * tickets_count
  end

  def event_has_enough_tickets
    return if event.nil?
    unless (event.tickets_sold + tickets_count) <= event.max_tickets
      errors.add(:event, "has only #{event.max_tickets - event.tickets_sold} tickets available")
    end
  end

  def event_available_for_payments
    if event.raising?
      errors.add :event, "is not available for payments now" unless DateTime.now <= event.raising_end
    elsif event.planned?
      errors.add :event, "is not available for payments now" unless DateTime.now <= event.date
    end
  end
end
