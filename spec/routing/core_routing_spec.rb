require 'spec_helper'

describe "core routing" do
  it "routes root to static#show" do
    {:get => "/"}.should route_to(
                             :controller => "static",
                             :action => "show"
                         )
  end
end