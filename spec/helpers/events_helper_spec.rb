require 'spec_helper'

describe EventsHelper do
  describe ":event_metadata method" do
    before do
      @opening_html = '<div class="meta row-fluid">'
      @closing_html = '</div>'
    end
    it "should render empty div if event is nil" do
      helper.event_metadata(nil).should == @opening_html + @closing_html
    end
    context "when there is an event" do
      before do
        @event = create :event
        @res = helper.event_metadata(@event)
      end
      subject { @res }
      context "when event is :raising" do
        before do
          @event = build :event, state: 'raising'
          @res = helper.event_metadata(@event)
        end
        it { should include('<div class="tickets') }
        it { should include('<div class="time') }
        it "should wrap result in appropriate div" do
          @res[0, @opening_html.length].should == @opening_html
          @res[@res.length - @closing_html.length, @res.length].should == @closing_html
        end
        it { should include(@event.tickets_sold.to_s) }
        it { should include("tickets sold") }
        it { should include(helper.distance_of_time_in_words_to_now(@event.raising_end)) }
      end
      context "when event is :planned" do
        before do
          @event = build :event, state: 'planned'
          @res = helper.event_metadata(@event)
        end
        it { should include('<div class="tickets') }
        it { should include('<div class="time') }
        it "should wrap result in appropriate div" do
          @res[0, @opening_html.length].should == @opening_html
          @res[@res.length - @closing_html.length, @res.length].should == @closing_html
        end
        it { should include((@event.max_tickets - @event.tickets_sold).to_s) }
        it { should include("tickets left") }
        it { should include(helper.distance_of_time_in_words_to_now(@event.date)) }
      end
      context "when event is :archived" do
        before do
          @event = build :event, state: 'archived'
          @res = helper.event_metadata(@event)
        end
        it "should wrap result in appropriate div" do
          @res[0, @opening_html.length].should == @opening_html
          @res[@res.length - @closing_html.length, @res.length].should == @closing_html
        end
        it { should include('<div class="tickets') }
        it { should include('<div class="time') }
        it { should include('is archived') }
        it { should include('tickets were sold') }
      end
    end
  end
  describe ":reserve_tickets_button" do
    subject { helper.reserve_tickets_button @event }
    context "when event is archived" do
      before do
        @event = create :event, state: 'archived'
      end
      it { should == "" }
    end
    context "when event is raising" do
      before do
        @event = create :event, state: 'raising'
      end
      it { should include("Reserve") }
      it { should include(@event.price.to_s) }
    end
    context "when event is planned" do
      before do
        @event = create :event, state: 'planned'
      end
      it { should include("Buy") }
      it { should include(@event.price.to_s) }
    end
  end
end