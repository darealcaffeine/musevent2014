FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@example.com" }
    role "user"
    sequence(:password) { |n| "testpass#{n}" }
    password_confirmation { |u| u.password }
  end

  factory :band do
    sequence(:title) { |n| "Band name #{n}" }
    description "Some band info"
  end

  factory :venue do
    sequence(:title) { |n| "Venue name #{n}" }
    address { |n| "Address of #{n}" }
    description "Some venue description"
    user
  end


  factory :admin, parent: :user do
    role "admin"
  end

  factory :guest, parent: :user do
    role 'guest'
  end

  factory :venue_manager, parent: :user do
    role 'venue_manager'
    venue
  end

  factory :event do
    sequence(:title) { |n| "This is event ##{n}" }
    venue
    band
    date DateTime.tomorrow + 5.days
    min_tickets 10
    max_tickets 100
    price 10.5
    description "Random text"
    raising_end DateTime.tomorrow + 1.day
  end

  factory :amazon_processor do

  end

  factory :dummy_processor do

  end

  factory :payment do
    event
    user
    processor { create :dummy_processor }
    tickets_count 1
  end

  factory :reserved_payment, parent: :payment do
    state :reserved
  end

  factory :expired_event, parent: :event do
    to_create { |instance| instance.save(validate: false) }
  end
end