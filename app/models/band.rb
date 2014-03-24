# == Schema Information
#
# Table name: bands
#
#  id                   :integer          not null, primary key
#  title                :string(255)
#  description          :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  events_count         :integer          default(0), not null
#  picture_file_name    :string(255)
#  picture_content_type :string(255)
#  picture_file_size    :integer
#  picture_updated_at   :datetime
#

# #ActiveRecord::Base subclass that represents band.
#
# == Relations
# has_many #Event
#
# == Validations
# * #title should be unique
# * #title and #description should be present
#
# == Special attributes
# #picture -- attached file (#Paperclip used)
class Band < ActiveRecord::Base
  has_many :events
  has_attached_file :picture, styles: {medium: "320x240#", thumb: "80x60#"}

  attr_accessible :title, :description, :event_ids, :picture

  validates :title, presence: true, uniqueness: true
  validates :description, presence: true

  # Calls method of superclass, overriding default options.
  #
  # <b>Default attributes:</b> #id, #title, #description, #created_at, #updated_at, #picture_url
  def as_json(options={})
    defaults = {
        only: [:id, :title, :description, :created_at, :updated_at],
        methods: 'picture_url'
    }
    super defaults.merge!(options)
  end

  # Proxy method for #picture.url, needed for #as_json method
  def picture_url(style=:medium)
    picture.url(style)
  end
end
