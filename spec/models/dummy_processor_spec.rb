# == Schema Information
#
# Table name: dummy_processors
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe DummyProcessor do
  before do
    @payment = create :payment, processor: DummyProcessor.new
    @processor = @payment.processor
  end

  it "should have valid factory" do
    (build :dummy_processor).should be_valid
  end
  it "should have one payment" do
    @processor.should have_one(:payment)
  end
  describe "'reserve' method" do
    before do
      @params = {id: @processor.id}
    end
    it "should exist" do
      lambda { @processor.reserve }.should_not raise_error(NoMethodError)
    end
    it "should take one argument" do
      lambda { @processor.reserve }.should raise_error(ArgumentError)
      lambda { @processor.reserve @params }.should_not raise_error(ArgumentError)
    end
    it "should make payment reserved" do
      @processor.reserve @params
      @processor.payment.state.should eq('reserved')
    end
    it "should raise 'Payment state should be :created' if payment status is wrong" do
      @payment.update_attributes state: 'reserved'
      lambda { @processor.reserve @params }.should raise_error(PreconditionsError, 'Payment state should be :created')
    end
  end
  describe "'settle' method" do
    it "should exist" do
      lambda { @processor.settle }.should_not raise_error(NoMethodError)
    end
    it "should make payment settled" do
      @processor.settle
      @processor.payment.state.should eq('settled')
    end
  end
  describe "'authorization_url' method" do
    before do
      @callback_url = "dummy_url"
    end
    it "should exist" do
      lambda { @processor.authorization_url }.should_not raise_error(NoMethodError)
    end
    it "should take one argument" do
      lambda { @processor.authorization_url }.should raise_error(ArgumentError)
      lambda { @processor.authorization_url @callback_url }.should_not raise_error(ArgumentError)
    end
    it "should return callback_url" do
      @processor.authorization_url(@callback_url).should eq(@callback_url)
    end
  end
  describe ":as_json method" do
    subject { @processor.as_json }
    it { should == {} }
  end
end
