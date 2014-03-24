require 'spec_helper'

describe StaticController do
  before do
    bypass_rescue
  end
  it "renders default view" do
    get :show
    response.should be_success
  end
  it "has index page as default view" do
    get :show
    response.should render_template('index')
  end
  it "renders view that corresponds to permalink" do
    get :show, permalink: "about"
    response.should be_success
    response.should render_template('about')
  end
  it "raises error if page doesn't exist" do
    lambda {get :show, permalink: "dummy123543"}.should(
        raise_error StaticPageMissing, "Static page 'dummy123543' not found"
    )
  end
end
