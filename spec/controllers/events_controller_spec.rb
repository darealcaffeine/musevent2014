require 'spec_helper'
describe EventsController do
  before do
    bypass_rescue
  end
  before do
    @per_page = 12
    28.times { create :event }
    @event = create :event
  end

  describe "GET index" do
    it "assigns first #@per_page events as @events" do
      get :index, {}
      assigns(:events).should include(@event)
      assigns(:events).count.should == @per_page
    end
    it "takes :page param into account" do
      get :index, {page: 2}
      assigns(:events).should_not include(@event)
      assigns(:events).count.should == @per_page
    end
    describe "filtering" do
      before do
        @band = create :band
        @venue = create :venue
        2.times do
          14.times { create :event, band: @band }
          5.times { create :event }
        end
        2.times do
          14.times { create :event, venue: @venue }
          5.times { create :event }
        end
        6.times do
          create :event, state: 'archived'
        end
      end
      describe ":filtering class variable" do
        before do
          get :index, {}
        end
        subject { assigns(:filtering) }
        it { should_not be_nil }
        it { should be_a(Hash) }
      end
      context "when :band_id is present" do
        before do
          @event = create :event, band: @band
          get :index, {band_id: @band.id}
        end
        it "should put band to :filtering" do
          assigns(:filtering)[:band].should == @band
        end
        it "should filter results by :band_id" do
          assigns(:events).count.should == @per_page
          assigns(:events).each { |event| event.band.should == @band }
          assigns(:events).should include(@event)
        end
        it "should paginate events correctly" do
          get :index, {band_id: @band.id, page: 2}
          assigns(:events).should_not include(@event)
          assigns(:events).count.should == @per_page
          assigns(:events).each { |event| event.band.should == @band }
        end
      end
      context "when :venue_id is present" do
        before do
          @event = create :event, venue: @venue
          get :index, {venue_id: @venue.id}
        end
        it "should put venue to :filtering" do
          assigns(:filtering)[:venue].should == @venue
        end
        it "should filter results by :venue_id" do
          assigns(:events).count.should == @per_page
          assigns(:events).each { |event| event.venue.should == @venue }
          assigns(:events).should include(@event)
        end
        it "should paginate events correctly" do
          get :index, {venue_id: @venue.id, page: 2}
          assigns(:events).should_not include(@event)
          assigns(:events).count.should == @per_page
          assigns(:events).each { |event| event.venue.should == @venue }
        end
      end
      context "when :state is present" do
        before do
          @event = create :event, state: 'archived'
          get :index, {state: 'archived'}
        end
        it "should put :state to filtering" do
          assigns(:filtering)[:state].should == @event.state
        end
        it "should filter results by :state" do
          assigns(:events).each { |event| event.state.should == 'archived' }
        end
      end
    end
  end

  describe "GET show" do
    it "assigns the requested event as @event" do
      get :show, {id: @event.to_param}
      assigns(:event).should eq(@event)
    end
  end

  describe "POST create" do
    before do
      @manager = create :venue_manager
      @venue = @manager.venue
    end
    before do
      @event_attr = attributes_for :event, venue_id: @venue.id, band_id: create(:band).id
    end

    context "when no user is logged in" do
      it "should raise error" do
        lambda { post :create, event: @event_attr }.should raise_error(CanCan::AccessDenied)
      end
    end

    context "when manager is logged in" do
      before do
        sign_in @manager
        post :create, event: @event_attr
      end

      it "should not raise error" do
        lambda { post :create, event: @event_attr }.should_not raise_error(CanCan::AccessDenied)
      end
      describe "response" do
        subject { response }
        it { should render_template('show') }
        it { should be_success }
      end
      describe "assigned event" do
        subject { assigns(:event) }
        it { should_not be_nil }
        it { should be_an(Event) }
        it { subject.id.should_not be_nil }
      end
    end
  end
end
