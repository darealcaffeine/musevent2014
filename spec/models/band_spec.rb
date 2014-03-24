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

require 'spec_helper'

describe Band do
  before do
    @band = create :band
  end
  subject { @band }
  it { should be_valid }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:description) }
  it { should have_many(:events) }
  it { should validate_uniqueness_of(:title) }
  it { should_not belong_to(:user) }
  describe ":as_json method" do
    subject { @band.as_json }
    it { should be_a(Hash) }
    it do
      should == {
          'title' => @band.title,
          'description' => @band.description,
          'id' => @band.id,
          'created_at' => @band.created_at,
          'updated_at' => @band.updated_at,
          'picture_url' => @band.picture.url(:medium)
      }
    end
  end
end
