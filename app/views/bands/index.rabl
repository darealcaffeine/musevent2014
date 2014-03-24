collection @bands
attributes :id, :title, :description, :created_at, :updated_at, :events_count
node :picture do |band|
  {
      thumb: band.picture.url(:thumb),
      medium: band.picture.url(:medium),
      original: band.picture.url(:original)
  }
end