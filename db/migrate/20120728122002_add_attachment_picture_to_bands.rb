class AddAttachmentPictureToBands < ActiveRecord::Migration
  def self.up
    add_attachment :bands, :picture
  end

  def self.down
    remove_attachment :bands, :picture
  end
end
