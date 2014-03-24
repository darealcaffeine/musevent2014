User.create! email: 'admin@example.com', password: 'password', role: 'admin'

band1 = Band.create! title: 'Test band 1', description: 'Just a first test band'
band2 = Band.create! title: 'Test band 2', description: 'Just a second test band'

venue1 = Venue.create! title: 'Test venue 1', address: 'Address of first venue', description: 'Just a first test venue'
venue2 = Venue.create!(
    title: 'Test venue 2', address: 'Address of second venue', description: 'Just a second test venue')
venue3 = Venue.create! title: 'Test venue 3', address: 'Address of third venue', description: 'Just a third test venue'

8.times { Event.create!({
                            title: "Random title #{rand}",
                            description: 'this is dummy event',
                            min_tickets: 5,
                            max_tickets: 10,
                            price: 30.2,
                            venue: venue1,
                            band_id: band1.id,
                            date: Date.today + 25.days,
                            raising_end: Date.today + 20.days
                        })
}

5.times { Event.create!({
                            title: "Another random title #{rand}",
                            description: 'this is dummy event',
                            min_tickets: 5,
                            max_tickets: 10,
                            price: 30.2,
                            venue: venue2,
                            band_id: band2.id,
                            date: Date.today + 25.days,
                            raising_end: Date.today + 20.days
                        })
}

12.times { Event.create!({
                             title: "Even more random title #{rand}",
                             description: 'this is dummy event',
                             min_tickets: 5,
                             max_tickets: 10,
                             price: 30.2,
                             venue: venue3,
                             band_id: band1.id,
                             date: Date.today + 25.days,
                             raising_end: Date.today + 20.days
                         })
}

4.times { Event.create!({
                            title: "Random title #{rand}",
                            description: 'this is dummy event',
                            min_tickets: 5,
                            max_tickets: 10,
                            price: 30.2,
                            venue: venue3,
                            band_id: band2.id,
                            date: Date.today + 25.days,
                            raising_end: Date.today + 20.days
                        })
}