require 'spec_helper'

describe VenuesController do
  before do
    bypass_rescue
  end
  describe "GET 'index'" do
    before do
      30.times { create :venue }
    end
    it "returns http success" do
      get 'index'
      response.should be_success
    end
    it "assigns 12 venues on 1st page" do
      get 'index'
      assigns(:venues).count.should == 12
    end
    it "takes :page param into account" do
      @venue = create :venue
      get 'index', {page: 2}
      assigns(:venues).count.should == 12
      assigns(:venues).should_not include(@venue)
    end
    describe "filtering" do
      before do
        @venue = create :venue
        create :event, venue: @venue
        @empty_venue = create :venue
        get 'index', {filter: 'active'}
      end
      describe ":filter class variable" do
        subject { assigns(:filter) }
        it { should_not be_nil }
        it { should == 'active' }
      end
      describe ":venues variable" do
        subject { assigns(:venues) }
        it { should include(@venue) }
        it { should_not include(@empty_venue) }
      end
    end
  end

  describe "GET 'show'" do
    before do
      @venue = create :venue
    end
    it "returns http success" do
      get 'show', {id: @venue.id}
      response.should be_success
    end
    it "assigns @venue" do
      get 'show', {id: @venue.id}
      assigns(:venue).should == @venue
    end
  end

  describe "GET 'create'" do
    context "when input is correct" do
      before do
        @manager = create :venue_manager, venue: nil
        @venue_attributes = attributes_for :venue, user: @manager
        sign_in @manager
        post 'create', venue: @venue_attributes
      end
      describe "assigned venue" do
        subject { assigns(:venue) }
        it { should be_a(Venue) }
        it { should_not be_new_record }
        it { subject.user.should == @manager }
      end
      describe "response" do
        subject { response }
        it { should be_success }
        it { should render_template('show') }
      end
    end
    context "when input data is wrong: " do
      it "manager is busy" do
        manager = create :venue_manager
        sign_in manager
        venue_attributes = attributes_for :venue, user: manager
        lambda { post 'create', venue: venue_attributes }.should raise_error(BusyManagerError)
      end
      it "user is not manager" do
        sign_in create(:user)
        lambda { post 'create', venue: attributes_for(:venue) }.should raise_error(CanCan::AccessDenied)
      end
    end
  end
end
