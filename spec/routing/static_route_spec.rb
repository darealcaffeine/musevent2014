require 'spec_helper'

describe "routing to static views" do
  it "routes /static/:permalink to static#show" do
    {:get => "/static/dummylink"}.should route_to(
                                             :controller => "static",
                                             :action => "show",
                                             :permalink => "dummylink"
                                         )
  end
  it "routes /static to static#show" do
    {:get => "/static"}.should route_to(
                                   :controller => "static",
                                   :action => "show"
                               )
  end
end