require 'spec_helper'
require "cancan/matchers"

describe Ability do
  let(:ability) { Ability.new(user) }
  subject { ability }

  context "when is guest" do
    let(:user) { nil }
    it { should be_able_to(:list, Event) }
    it { should be_able_to(:show, Event, state: %w(raising planned)) }
    it { should_not be_able_to(:create, Payment) }
    it { should_not be_able_to(:show, Payment) }
    it { should_not be_able_to(:access, :rails_admin) }
    it { should be_able_to(:show, Venue) }
    it { should be_able_to(:list, Venue) }
    it { should be_able_to(:show, Band) }
    it { should be_able_to(:list, Band) }
  end

  context "when is user" do
    let(:user) { create :user }
    it { should be_able_to(:list, Event) }
    it { should be_able_to(:show, Event, state: %w(raising planned)) }
    it { should be_able_to(:create, Payment) }
    it { should be_able_to(:show, Payment, user_id: user.id) }
    it { should be_able_to(:destroy, Payment, user_id: user.id) }
    it { should_not be_able_to(:access, :rails_admin) }
    it { should be_able_to(:reserve, Payment, user_id: user.id) }
    it { should be_able_to(:show, Venue) }
    it { should be_able_to(:list, Venue) }
    it { should be_able_to(:show, Band) }
    it { should be_able_to(:list, Band) }
    it { should_not be_able_to(:manage, Event) }
  end

  context "when is venue_manager" do
    let(:user) { create :venue_manager }
    it { should be_able_to(:manage, user.venue) }
    it { should_not be_able_to(:manage, create(:venue)) }
    it "should be able to manage events of his venue" do
      event = create :event, venue: user.venue
      should be_able_to(:manage, event)
    end
    it { should be_able_to(:create, Venue) }
  end

  context "when is admin" do
    let(:user) { create :admin }
    it { should be_able_to(:manage, :all) }
    it { should be_able_to(:access, :rails_admin) }
  end
end