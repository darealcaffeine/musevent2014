# == Schema Information
#
# Table name: venues
#
#  id                   :integer          not null, primary key
#  title                :string(255)
#  address              :string(255)
#  description          :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  events_count         :integer          default(0), not null
#  picture_file_name    :string(255)
#  picture_content_type :string(255)
#  picture_file_size    :integer
#  picture_updated_at   :datetime
#

class Venue < ActiveRecord::Base
  has_attached_file :picture, styles: {medium: "320x240#", thumb: "80x60#"}
  has_many :events
  belongs_to :user
  validates_presence_of :user
  attr_accessible :address, :title, :description, :event_ids, :picture
  validates :title, presence: true
  validates :address, presence: true
  validates :description, presence: true

  def as_json(options={})
    defaults = {
        only: [:id, :title, :address, :description, :created_at, :updated_at],
        methods: 'picture_url'
    }
    super defaults.merge!(options)
  end

  def picture_url(style=:medium)
    picture.url(style)
  end
end
