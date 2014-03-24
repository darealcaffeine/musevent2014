require "spec_helper"

describe EventsController do
  describe "routing" do
    it "routes to #index" do
      get("/events").should route_to("events#index")
    end

    it "routes to #show" do
      get("/events/1").should route_to("events#show", :id => "1")
    end

    it "routes to #index with 'state: archive' for '/archive'" do
      get("/events/archive").should route_to("events#index", state: 'archived')
    end

    it "routes to #create" do
      post('/events').should route_to("events#create")
    end
  end

  describe "Payments routing" do

    it "should route GET /payments/new to payments#new" do
      {:get => '/events/1/payments/new'}.should route_to(controller: 'payments', action: 'new', event_id: '1')
    end

    it "should route POST /payments to payments#create" do
      {:post => '/events/1/payments'}.should route_to(controller: 'payments', action: 'create', event_id: '1')
    end

    it "should not route GET /payments/:id to payments#show" do
      {:get => '/events/1/payments/12'}.should_not route_to(controller: 'payments', action: 'show', id: '12', event_id: '1')
    end
  end
end
