# == Schema Information
#
# Table name: events
#
#  id                   :integer          not null, primary key
#  title                :string(255)
#  date                 :datetime
#  min_tickets          :integer
#  max_tickets          :integer
#  price                :decimal(, )
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  state_cd             :integer          default(0)
#  description          :text
#  raising_end          :datetime
#  band_id              :integer
#  venue_id             :integer
#  picture_file_name    :string(255)
#  picture_content_type :string(255)
#  picture_file_size    :integer
#  picture_updated_at   :datetime
#
# Indexes
#
#  index_events_on_band_id   (band_id)
#  index_events_on_venue_id  (venue_id)
#

require 'spec_helper'

describe Event do
  before :each do
    @event = create :event
    subject { @event }
  end

  it "should have valid factory" do
    @event.should be_valid
  end

  it "has state field" do
    @event.state.should_not be_nil
  end

  it { should have_many :payments }
  it { should belong_to(:band) }
  it { should validate_presence_of(:band) }
  it { should belong_to(:venue) }
  it { should validate_presence_of(:venue) }

  describe "'raising_percentage' method result" do
    it "should be number" do
      @event.raising_percentage.should be_a(Fixnum)
    end
    it "should be raised_funds / (min_tickets * price)  * 100%" do
      create :payment, event: @event
      expected = @event.raised_funds / (@event.min_tickets * @event.price) * 100.0
      @event.raising_percentage.should eq(expected)
    end
    it "should be 0 if :raised_funds is 0" do
      @event.raised_funds = 0;
      @event.raising_percentage.should == 0
    end
  end

  describe ":tickets_sold method" do
    it "should exist" do
      lambda { @event.tickets_sold }.should_not raise_error(NoMethodError)
    end
    it "should return correct value" do
      10.times do
        create :payment, event: @event, tickets_count: 2
      end
      @event.tickets_sold.should == 20
    end
  end

  describe ":raised_funds method" do
    it "should exist" do
      lambda { @event.raised_funds }.should_not raise_error(NoMethodError)
    end
    it "should compute value as sum of associated payments amount" do
      10.times do
        create :payment, event: @event, tickets_count: 3
      end
      @event.raised_funds.should == @event.payments.sum('amount')
    end
  end

  describe "should validate that" do
    describe ":min_tickets" do
      it "is present" do
        should validate_presence_of :min_tickets
      end
      it "is integer number" do
        should validate_numericality_of(:min_tickets).only_integer
      end
      it "is positive" do
        @event.min_tickets = -5
        @event.save.should be_false
      end
      it "is less than :max_tickets" do
        @event.min_tickets = 100
        @event.max_tickets = 50
        @event.save.should be_false
      end
    end

    describe ":max_tickets" do
      it "is present" do
        should validate_presence_of :max_tickets
      end
      it "is integer number" do
        should validate_numericality_of(:max_tickets).only_integer
      end
      it "is positive" do
        @event.max_tickets = -5
        @event.save.should be_false
      end
    end

    describe ":price" do
      it "is present" do
        should validate_presence_of :price
      end
      it "is number" do
        should validate_numericality_of(:price)
      end
      it "is positive" do
        @event.price = -5.4
        @event.save.should be_false
      end
    end

    it ":title, :venue, :band, :description are present" do
      should validate_presence_of :title
      should validate_presence_of :venue
      should validate_presence_of :band
      should validate_presence_of :description
    end

    describe ":date" do
      it "is present" do
        should validate_presence_of :date
      end
    end

    describe ":raising_end" do
      it "is present" do
        should validate_presence_of :raising_end
      end
      it "is before :date" do
        @event.raising_end = Date.tomorrow
        @event.date = Date.today
        @event.save.should be_false
      end
    end
  end

  describe ":as_json method" do
    subject { @event.as_json }
    it { should be_a(Hash) }
    it do
      should == {
          'title' => @event.title,
          'band_id' => @event.band_id,
          'venue_id' => @event.venue_id,
          'date' => @event.date,
          'raising_end' => @event.raising_end,
          'price' => @event.price,
          'min_tickets' => @event.min_tickets,
          'max_tickets' => @event.max_tickets,
          'tickets_sold' => @event.tickets_sold,
          'state' => @event.state,
          'picture_url' => @event.picture.url(:modal),
          'created_at' => @event.created_at,
          'updated_at' => @event.updated_at,
          'id' => @event.id,
          'description' => @event.description
      }
    end
  end
end

