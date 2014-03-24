require "spec_helper"

describe EventMailer do
  before do
    @event = create :event
    @user = create :user
  end
  describe ":notify_raising_success" do
    subject { EventMailer.notify_raising_success @event, @user }
    it { should be_a(Mail::Message) }
    it { subject.from.should include("events_robot@musevent.com") }
    it { subject.subject.should == "#{@event.title} event successfully finished fund raising company" }
    it { subject.to.should == [@user.email] }
  end
  describe ":notify_raising_failure" do
    subject { EventMailer.notify_raising_failure @event, @user }
    it { should be_a(Mail::Message) }
    it { subject.from.should include("events_robot@musevent.com") }
    it { subject.subject.should == "#{@event.title} event failed fund raising company" }
    it { subject.to.should == [@user.email] }
  end
end
