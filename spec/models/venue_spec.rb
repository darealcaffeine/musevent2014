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

require 'spec_helper'

describe Venue do
  before do
    @venue = build :venue
  end
  subject { @venue }
  it { should be_valid }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:address) }
  it { should validate_presence_of(:description) }
  it { should have_many(:events) }
  it { should belong_to(:user) }
  it { should validate_presence_of(:user) }

  describe ":as_json method" do
    subject { @venue.as_json }
    it { should be_a(Hash) }
    it do
      should == {
          'title' => @venue.title,
          'description' => @venue.description,
          'id' => @venue.id,
          'created_at' => @venue.created_at,
          'updated_at' => @venue.updated_at,
          'picture_url' => @venue.picture.url(:medium),
          'address' => @venue.address
      }
    end
  end
end
