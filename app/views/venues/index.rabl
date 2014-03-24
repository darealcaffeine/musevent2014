collection @venues
attributes :id, :title, :address, :description, :created_at, :updated_at, :events_count
node :picture do |venue|
  {
      thumb: venue.picture.url(:thumb),
      medium: venue.picture.url(:medium),
      original: venue.picture.url(:original)
  }
end