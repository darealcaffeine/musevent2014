require "spec_helper"

describe "Venues routing" do
  it "routes '/venues/' to venues#index" do
    get('/venues/').should route_to("venues#index")
  end
  it "routes 'venues/:id' to venues#show" do
    get('/venues/12/').should route_to("venues#show", id: "12")
  end
  it "routes 'venues/:id/events' to events#index" do
    get('/venues/12/events').should route_to("events#index", venue_id: "12")
  end
  it "routes 'POST venues/' to 'venues#create'" do
    post('/venues').should route_to("venues#create")
  end
end