RailsAdmin.config do |config|
  config.current_user_method { current_user } # auto-generated
  config.authorize_with :cancan
  config.main_app_name = ['MusEvent', 'Admin']

  config.actions do
    dashboard
    index
    new do
      visible do
        !bindings[:abstract_model].model_name.in? %w(Payment).concat Payment.processor_types
      end
    end
    bulk_delete
    show
    edit do
      visible do
        !bindings[:abstract_model].model_name.in? Payment.processor_types
      end
    end
    delete do
      visible do
        !bindings[:abstract_model].model_name.in? Payment.processor_types
      end
    end
    show_in_app do
      visible do
        bindings[:abstract_model].model_name.in? %w(Event Venue Band)
      end
    end
  end

  config.model Band do
    list do
      field :title
      field :created_at
      field :updated_at
      field :events_count
    end
    edit do
      field :title
      field :description
      field :picture, :paperclip
    end
    update do
      field :events
    end
    show do
      field :title
      field :description
      field :events
      field :picture
    end
  end

  config.model Venue do
    list do
      field :title
      field :address
      field :created_at
      field :updated_at
      field :events_count
    end
    edit do
      field :title
      field :description
      field :address
      field :picture, :paperclip
    end
    update do
      field :events
    end
    show do
      field :title
      field :address
      field :description
      field :events
      field :picture
    end
  end

  config.model User do
    edit do
      field :email
      field :password
      field :role, :enum do
        enum do
          User.roles_for_select
        end
      end
    end
    list do
      field :email
      field :role
      field :updated_at
    end
    show do
      field :id
      field :email
      field :role
    end
  end

  config.model Event do
    list do
      field :title
      field :venue
      field :band
      field :state
      field :raising_end
      field :date
    end
    edit do
      field :title
      field :description
      field :picture, :paperclip
      field :venue
      field :band
      field :min_tickets
      field :max_tickets
      field :raising_end
      field :date
      field :price
    end
    update do
      field :state, :enum do
        enum { Event.states_for_select }
      end
    end
    show do
      field :title
      field :state
      field :description
      field :picture
      field :venue
      field :band
      field :raising_end
      field :date
      field :price
      field :min_tickets
      field :max_tickets
      field :tickets_sold
    end
  end

  config.model Payment do
    list do
      field :event
      field :user
      field :tickets_count
      field :state
      field :updated_at
      field :amount
    end
    # there is no :create
    edit do
      field :event
      field :user
      field :tickets_count
    end
    show do
      field :event
      field :user
      field :tickets_count
      field :amount
      field :processor
      field :state
      field :created_at
      field :updated_at
    end
  end

  config.model AmazonProcessor do
    parent Payment
  end

  config.model DummyProcessor do
    parent Payment
    list do
      field :payment
      field :created_at
      field :id
    end
  end
end
