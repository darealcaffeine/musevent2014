require "spec_helper"

describe "Bands routing" do
  it "routes '/bands/' to bands#index" do
    get('/bands/').should route_to("bands#index")
  end
  it "routes 'bands/:id' to bands#show" do
    get('/bands/12/').should route_to("bands#show", id: "12")
  end
  it "routes 'bands/:id/events' to events#index" do
    get('/bands/12/events').should route_to("events#index", band_id: "12")
  end
end