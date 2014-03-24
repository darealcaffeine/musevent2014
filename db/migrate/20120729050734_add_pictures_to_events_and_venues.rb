class AddPicturesToEventsAndVenues < ActiveRecord::Migration
  def change
    add_attachment :events, :picture
    add_attachment :venues, :picture
  end
end
