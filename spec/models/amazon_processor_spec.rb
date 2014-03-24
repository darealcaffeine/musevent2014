# == Schema Information
#
# Table name: amazon_processors
#
#  id               :integer          not null, primary key
#  transaction_id   :string(255)      default("")
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  caller_reference :string(255)
#

require 'spec_helper'

describe AmazonProcessor do
  before do
    @payment = create :payment, processor: AmazonProcessor.new
    @amazon_payment = @payment.processor
    @remit = Remit::API.new(FPS_ACCESS_KEY, FPS_SECRET_KEY, true)
    Remit::API.should_receive(:new).any_number_of_times.and_return(@remit)
  end
  subject { @amazon_payment }
  it "has valid factory" do
    @amazon_payment.should be_valid
  end
  it { should have_one(:payment) }

  describe "reserve method" do
    before do
      @params = {
          signature: 'stub',
          signatureVersion: '2',
          signatureMethod: 'RSA-SHA1',
          certificateUrl: 'stub',
          callerReference: 'stub',
          status: 'SC',
          expiry: 'stub',
          tokenID: 'stubTokenID'
      }
    end
    subject { lambda { @amazon_payment.reserve @params } }
    it "should require hash as argument" do
      lambda { @amazon_payment.reserve }.should raise_error(ArgumentError)
      should_not raise_error(ArgumentError)
    end
    it "should raise error if argument is invalid" do
      AmazonProcessor.should_receive(:validate_reservation_response).with(@params).and_raise(MalformedServiceResponseError)
      should raise_error(MalformedServiceResponseError)
    end
    it "should raise 'Payment state should be :created' if payment status is wrong" do
      @payment.update_attributes state: 'reserved'
      should raise_error(PreconditionsError, 'Payment state should be :created')
    end
    context "with valid arguments" do
      before :each do
        @remit = Remit::API.new(FPS_ACCESS_KEY, FPS_SECRET_KEY, true)

        @transaction_id = "14GK6F2QU755ODS27SGHEURLKPG72Z54KMF"
        doc = <<-XML
        <ReserveResponse xmlns="http://fps.amazonaws.com/doc/2008-09-17/">
          <ReserveResult>
            <TransactionId>#{@transaction_id}</TransactionId>
            <TransactionStatus>Pending</TransactionStatus>
          </ReserveResult>
          <ResponseMetadata>
            <RequestId>1a146b9a-b37b-4f5f-bda6-012a5b9e45c3:0</RequestId>
          </ResponseMetadata>
        </ReserveResponse>
        XML

        @success_response = Remit::Reserve::Response.new(doc)
        @amazon_payment.should_receive(:recipient_token).and_return("rec token")
      end
      context "when API interaction succeeded" do
        before :each do
          @remit.should_receive(:reserve).and_return(@success_response)
        end
        it "should save reservation token to db" do
          @amazon_payment.reserve @params
          AmazonProcessor.find(@amazon_payment.id).transaction_id.should == @transaction_id
        end
        it "should save caller_reference" do
          lambda { @amazon_payment.reserve @params }.should change(@amazon_payment, :caller_reference)
        end
      end
      context "when API interaction failed" do
        before do
          @error_response = @success_response.clone
          @error_response.errors << "error"
        end
        it "should raise error" do
          @remit.should_receive(:reserve).and_return(@error_response)
          should raise_error(ApiInteractionError, @error_response.errors.join('; '))
        end
      end
    end
  end

  describe "settle method" do
    it "should raise 'Transaction id is required' if transaction_id is nil or empty" do
      @amazon_payment.transaction_id = nil
      lambda { @amazon_payment.settle }.should raise_error(PreconditionsError, 'Transaction id is required')
      @amazon_payment.transaction_id = ""

      lambda { @amazon_payment.settle }.should raise_error(PreconditionsError, 'Transaction id is required')
    end

    it "should raise 'Payment should be reserved' if payment status is not 'reserved'" do
      @payment.state = 'settled'
      @amazon_payment.transaction_id = "some_token" # to pass validation

      lambda { @amazon_payment.settle }.should raise_error(PreconditionsError, "Payment should be reserved")
    end
    context "with correct preconditions" do
      before :each do
        @transaction_id = "14GK6F2QU755ODS27SGHEURLKPG72Z54KMF"
        doc = <<-XML
        <SettleResponse xmlns="http://fps.amazonaws.com/doc/2008-09-17/">
          <SettleResult>
            <TransactionId>#{@transaction_id}</TransactionId>
            <TransactionStatus>Pending</TransactionStatus>
          </SettleResult>
          <ResponseMetadata>
            <RequestId>1a146b9a-b37b-4f5f-bda6-012a5b9e45c3:0</RequestId>
          </ResponseMetadata>
        </SettleResponse>
        XML

        @success_response = Remit::Settle::Response.new(doc)
        @payment = create :reserved_payment, processor: AmazonProcessor.new
        @amazon_payment = @payment.processor
        @amazon_payment.update_attribute :transaction_id, @transaction_id
      end
      context "when API interaction succeeded" do
        before :each do
          @remit.should_receive(:settle).and_return(@success_response)
        end
        it "should make payment settled" do
          @amazon_payment.settle
          @amazon_payment.payment.state.should eq('settled')
        end
        it "should make a 'Settle' API call" do
          @amazon_payment.settle
        end
      end
      context "when API interaction failed" do
        before do
          @error_response = @success_response.clone
          @error_response.errors << "error"
        end
        it "should raise error" do
          @remit.should_receive(:settle).and_return(@error_response)
          lambda { @amazon_payment.settle }.should raise_error(ApiInteractionError, @error_response.errors.join('; '))
        end
      end
    end
  end

  describe "authorize_url method" do
    it "should take at least one argument" do
      lambda { @amazon_payment.authorization_url }.should raise_error(ArgumentError)
    end

    it "should return string" do
      @amazon_payment.authorization_url('test_callback').should be_a(String)
    end

    it "should return url" do
      url = @amazon_payment.authorization_url('test_callback')
      URI.parse(url).should be_an(URI)
    end

    describe "response" do
      before do
        @url = URI.parse @amazon_payment.authorization_url('test_callback')
      end

      it "path should be '/cobranded-ui/actions/start'" do
        @url.path().should eq('/cobranded-ui/actions/start')
      end

      it "scheme should be 'https'" do
        @url.scheme().should eq('https')
      end

      it "host should be 'authorize.payments-sandbox.amazon.com'" do
        @url.host().should eq('authorize.payments-sandbox.amazon.com')
      end

      describe "parameter" do
        before do
          @params = CGI.parse(@url.query)
        end
        it "'pipelineName' should be SingleUse" do
          @params['pipelineName'].length.should eq(1)
          @params['pipelineName'][0].should eq('SingleUse')
        end
        it "'returnURL' should be 'test_callback'" do
          @params['returnURL'].length.should eq(1)
          @params['returnURL'][0].should eq('test_callback')
        end
        it "'signature' should be present" do
          @params['signature'].length.should eq(1)
        end
        it "'signatureMethod' should be 'HmacSHA256'" do
          @params['signatureMethod'].length.should eq(1)
          @params['signatureMethod'][0].should eq('HmacSHA256')
        end
        it "'signatureVersion' should be 2" do
          @params['signatureVersion'].length.should eq(1)
          @params['signatureVersion'][0].to_i.should eq(2)
        end
        it "'transactionAmount' should be taken from payment data" do
          @params['transactionAmount'].length.should eq(1)
          @params['transactionAmount'][0].to_f.should eq(@payment.amount)
        end
      end
    end
  end

  describe "validate_reservation_response class method" do
    before do
      @params = {
          signature: 'stub',
          signatureVersion: '2',
          signatureMethod: 'RSA-SHA1',
          certificateUrl: 'stub',
          callerReference: 'stub'
      }
    end

    context "when payment succeeded" do
      before do
        @params.update({status: 'SC', expiry: 'stub', tokenID: 'stubTokenID'})
      end
      it "should raise 'Malformed request' if 'tokenID' is missing" do
        @params[:tokenID] = nil
        lambda { AmazonProcessor.validate_reservation_response @params }.should(
            raise_error(MalformedServiceResponseError, "'tokenID' is missing")
        )
      end
    end

    context "when payment failed" do
      before do
        @params.update({status: 'NP', errorMessage: 'stubErrorMessage'})
      end
      it "should raise error message text" do
        lambda { AmazonProcessor.validate_reservation_response @params }.should(
            raise_error(ApiInteractionError, @params[:errorMessage]))
      end
    end

    describe "basic params check" do
      before :each do
        @params = {
            status: 'NC',
            signature: 'stub',
            signatureVersion: '2',
            signatureMethod: 'RSA-SHA1',
            certificateUrl: 'stub',
            callerReference: 'stub'
        }
      end
      it "should raise 'Malformed request' if 'status' is missing" do
        @params.delete :status
        lambda { AmazonProcessor.validate_reservation_response @params }.should(
            raise_error(MalformedServiceResponseError, "'status' is missing"))
      end
      it "should raise 'Malformed request' if 'signature' is missing" do
        @params.delete :signature
        lambda { AmazonProcessor.validate_reservation_response @params }.should(
            raise_error(MalformedServiceResponseError, "'signature' is missing"))
      end
      it "should raise 'Malformed request' if 'signatureVersion' is missing" do
        @params.delete :signatureVersion
        lambda { AmazonProcessor.validate_reservation_response @params }.should(
            raise_error(MalformedServiceResponseError, "'signatureVersion' is missing"))
      end
      it "should raise 'Malformed request' if 'signatureMethod' is missing" do
        @params.delete :signatureMethod
        lambda { AmazonProcessor.validate_reservation_response @params }.should(
            raise_error(MalformedServiceResponseError, "'signatureMethod' is missing"))
      end
      it "should raise 'Malformed request' if 'certificateUrl' is missing" do
        @params.delete :certificateUrl
        lambda { AmazonProcessor.validate_reservation_response @params }.should(
            raise_error(MalformedServiceResponseError, "'certificateUrl' is missing"))
      end
      it "should raise 'Unknown status' if 'status' has wrong value" do
        @params[:status] = 'someInvalidValue'
        lambda { AmazonProcessor.validate_reservation_response @params }.should(
            raise_error(MalformedServiceResponseError, "'someInvalidValue' is unknown falue for 'status'"))
      end
    end
  end

  describe "release method" do
    before do
      @request = Remit::Cancel::Request.new(transaction_id: @amazon_payment.transaction_id)
      @remit = Remit::API.new(FPS_ACCESS_KEY, FPS_SECRET_KEY, true)
      doc = <<-XML
        <CancelResponse xmlns="http://fps.amazonaws.com/doc/2008-09-17/">
          <CancelResult>
            <TransactionId>#{@amazon_payment.transaction_id}</TransactionId>
            <TransactionStatus>Pending</TransactionStatus>
          </CancelResult>
          <ResponseMetadata>
            <RequestId>1a146b9a-b37b-4f5f-bda6-012a5b9e45c3:0</RequestId>
          </ResponseMetadata>
        </CancelResponse>
      XML
      @success_response = Remit::Cancel::Response.new(doc)
    end
    subject { @amazon_payment.release }
    before :each do
      Remit::Cancel::Request.should_receive(:new).with(
          transaction_id: @amazon_payment.transaction_id).and_return @request
    end
    context "when operation succeeded" do
      before :each do
        @remit.should_receive(:cancel).with(@request).and_return @success_response
      end
      it { should be_true }
    end
    context "when operation failed" do
      before do
        @failed_response = @success_response.clone
        @failed_response.errors << "error"
      end
      before :each do
        @remit.should_receive(:cancel).with(@request).and_return @failed_response
      end
      it { should be_false }
    end
  end
  describe "refund method" do
    before do
      @amazon_payment.update_attribute :caller_reference, 'test'
      @request = Remit::Refund::Request.new(
          transaction_id: @amazon_payment.transaction_id, caller_reference: @amazon_payment.caller_reference)
      @remit = Remit::API.new(FPS_ACCESS_KEY, FPS_SECRET_KEY, true)
      doc = <<-XML
        <RefundResponse xmlns="http://fps.amazonaws.com/doc/2008-09-17/">
          <RefundResult>
            <TransactionId>#{@amazon_payment.transaction_id}</TransactionId>
            <TransactionStatus>Pending</TransactionStatus>
          </RefundResult>
          <ResponseMetadata>
            <RequestId>1a146b9a-b37b-4f5f-bda6-012a5b9e45c3:0</RequestId>
          </ResponseMetadata>
        </RefundResponse>
      XML
      @success_response = Remit::Cancel::Response.new(doc)
    end
    subject { @amazon_payment.refund }
    before :each do
      Remit::Refund::Request.should_receive(:new).with(
          transaction_id: @amazon_payment.transaction_id, caller_reference: @amazon_payment.caller_reference
      ).and_return @request
    end
    context "when operation succeeded" do
      before :each do
        @remit.should_receive(:refund).with(@request).and_return @success_response
      end
      it { should be_true }
    end
    context "when operation failed" do
      before do
        @failed_response = @success_response.clone
        @failed_response.errors << "error"
      end
      before :each do
        @remit.should_receive(:refund).with(@request).and_return @failed_response
      end
      it { should be_false }
    end
  end
  describe ":as_json method" do
    subject { @amazon_payment.as_json }
    it { should == {} }
  end
end
