require "spec_helper"

describe PaymentsController do
  describe "routing" do
    it "routes to #index" do
      get("/payments").should route_to("payments#index")
    end
    it "should route GET /payments/:id/reserve to payments#reserve" do
      {:get => '/payments/12/reserve'}.should route_to(controller: 'payments', action: 'reserve', id: '12')
    end
    it "routes to #show" do
      {:get => '/payments/12'}.should route_to(controller: 'payments', action: 'show', id: '12')
    end
    it "routes to #delete" do
      {:delete => '/payments/12'}.should route_to(controller: 'payments', action: 'destroy', id: '12')
    end
  end
end