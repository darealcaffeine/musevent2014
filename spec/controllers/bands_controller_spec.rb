require 'spec_helper'

describe BandsController do
  before do
    bypass_rescue
  end
  describe "GET 'index'" do
    before do
      30.times { create :band }
      @band = create :band
    end

    before { get 'index' }
    it { response.should be_success }
    it { assigns(:bands).count.should == 12 }
    it { assigns(:bands).should include(@band) }
    context "with :page param" do
      before { get 'index', {page: 2} }
      it { assigns(:bands).count.should == 12 }
      it { assigns(:bands).should_not include(@band) }
    end
    describe "filtering" do
      before do
        create :event, band: @band
        @empty_band = create :band
        get 'index', {filter: 'active'}
      end
      describe ":filter class variable" do
        subject { assigns(:filter) }
        it { should_not be_nil }
        it { should == 'active' }
      end
      describe ":bands variable" do
        subject { assigns(:bands) }
        it { should include(@band) }
        it { should_not include(@empty_band) }
      end
    end
  end

  describe "GET 'show'" do
    before do
      @band = create :band
    end
    it "returns 200 for correct id" do
      get 'show', {id: @band.id}
      response.should be_success
    end
    it "assigns @band" do
      get 'show', {id: @band.id}
      assigns(:band).should == @band
    end
    it "raises error if id is incorrect" do
      lambda { get 'show', {id: 80085} }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
