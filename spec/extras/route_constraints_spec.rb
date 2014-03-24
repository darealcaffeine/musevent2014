require "spec_helper"

class RequestStub
  attr_accessor :env
  attr_accessor :path_parameters
  attr_accessor :query_parameters

  def initialize
    @env = {"HTTP_USER_AGENT" => 'Chrome'}
    @path_parameters = {format: 'html', test: true}
    @query_parameters = {}
  end
end

describe RouteConstraints do
  describe RouteConstraints::JsEnabled do
    before do
      @constraint = RouteConstraints::JsEnabled.new
    end
    before :each do
      @request = RequestStub.new
    end
    it "should not match when USER_AGENT contains 'bot'" do
      @request.env['HTTP_USER_AGENT'] = 'googlebotcrawler'
      @constraint.matches?(@request).should be_false
    end
    it "should not match when :simple param is set" do
      @request.query_parameters[:simple] = true
      @constraint.matches?(@request).should be_false
    end
    it "should not match when :format is :json" do
      @request.path_parameters[:format] = 'json'
      @constraint.matches?(@request).should be_false
    end
    it "should match any other request" do
      @constraint.matches?(@request).should be_true
    end
  end
end