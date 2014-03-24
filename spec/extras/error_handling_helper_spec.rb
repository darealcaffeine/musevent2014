require "spec_helper"

include ErrorHandlingHelper

describe ErrorHandlingHelper do
  describe ":status_for_error method" do
    it "should return 400 for RenderedError" do
      status_for_error(RenderedError.new).should == 400
    end
    it "should return 403 for CanCan::AccessDenied" do
      status_for_error(CanCan::AccessDenied.new).should == 403
    end
    it "should return 404 for ActiveRecord::RecordNotFound" do
      status_for_error(ActiveRecord::RecordNotFound.new).should == 404
    end
    it "should return 500 for any StandardError" do
      status_for_error(StandardError.new("random error")).should == 500
    end
  end
end