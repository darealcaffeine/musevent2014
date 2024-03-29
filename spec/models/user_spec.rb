# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  role_cd                :integer          default(1)
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

require 'spec_helper'

describe User do
  it "has valid factory" do
    (build :user).should be_valid
  end
  it "rejects wrong role" do
    user = create :user
    lambda { user.role = "fail" }.should raise_error(ArgumentError)
  end
  it "has many payments" do
    should have_many :payments
  end

  it { should_not have_and_belong_to_many(:bands) }
  it { should_not have_and_belong_to_many(:venues) }
  it { should have_one(:venue) }
end
