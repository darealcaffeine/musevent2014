# == Schema Information
#
# Table name: events
#
#  id                   :integer          not null, primary key
#  title                :string(255)
#  date                 :datetime
#  min_tickets          :integer
#  max_tickets          :integer
#  price                :decimal(, )
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  state_cd             :integer          default(0)
#  description          :text
#  raising_end          :datetime
#  band_id              :integer
#  venue_id             :integer
#  picture_file_name    :string(255)
#  picture_content_type :string(255)
#  picture_file_size    :integer
#  picture_updated_at   :datetime
#
# Indexes
#
#  index_events_on_band_id   (band_id)
#  index_events_on_venue_id  (venue_id)
#

class Event < ActiveRecord::Base
  has_attached_file :picture, styles: {medium: "320x240#", thumb: "80x60#"}
  has_many :payments
  belongs_to :band, counter_cache: true
  belongs_to :venue, counter_cache: true
  delegate :title, to: :venue, prefix: true
  delegate :title, to: :band, prefix: true

  attr_accessible :band_id, :venue_id, :date, :max_tickets, :min_tickets, :price, :title, :venue, :payment_ids, :state,
                  :description, :raising_end, :picture

  validates_presence_of :band, :date, :title, :venue, :description, :raising_end
  validate :raising_ends_before_event_date, unless: 'raising_end.nil? or date.nil?'
  validate :min_tickets_is_lte_max_tickets, unless: 'min_tickets.nil? or max_tickets.nil?'

  validates :min_tickets, presence: true, numericality: {only_integer: true, greater_than: 0}
  validates :max_tickets, presence: true, numericality: {only_integer: true, greater_than: 0}
  validates :price, presence: true, numericality: {greater_than: 0}

  as_enum :state, %w(raising planned archived), dirty: true, slim: :class

  def raising_percentage
    return 0 if raised_funds.nil? or 0 == raised_funds
    raised_funds / (min_tickets * price) * 100.0
  end

  def tickets_sold
    payments.sum('tickets_count')
  end

  def raised_funds=(val)
    # do nothing
  end

  def raised_funds
    payments.sum('amount')
  end

  def as_json(options={})
    defaults = {
        only: [:band_id, :created_at, :updated_at, :date, :description, :id, :max_tickets, :min_tickets,
               :price, :raising_end, :title, :updated_at, :venue_id],
        methods: ['picture_url', 'tickets_sold', 'state']
    }
    super defaults.merge!(options)
  end

  def picture_url(style=:modal)
    picture.url(style)
  end

  private

  def min_tickets_is_lte_max_tickets
    errors.add :min_tickets, "should not be more than max tickets" unless min_tickets <= max_tickets
  end

  def raising_ends_before_event_date
    unless raising_end < date
      errors.add :raising_end, "should be before the event date"
    end
  end
end
