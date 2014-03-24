Musevent::Application.routes.draw do
  get '(*path)' => 'static#application',
      constraints: RouteConstraints::JsEnabled.new
  resources :events, only: [:index, :show, :create] do
    resources :payments, only: [:new, :create]
    collection do
      get 'archive', to: "events#index", defaults: {state: 'archived'}
    end
  end

  resources :venues, only: [:index, :show, :create] do
    resources :events, only: :index
  end

  resources :bands, only: [:index, :show] do
    resources :events, only: :index
  end

  resources :payments, only: [:index, :show, :destroy] do
    member do
      get 'reserve'
    end
  end

  root to: "static#show"
  get "static(/:permalink)" => "static#show"
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  devise_for :users
end
#== Route Map
# Generated on 05 Aug 2012 19:43
#
#        new_event_payment GET    /events/:event_id/payments/new(.:format) payments#new
#           archive_events GET    /events/archive(.:format)                events#index {:state=>"archived"}
#                   events GET    /events(.:format)                        events#index
#                    event GET    /events/:id(.:format)                    events#show
#             venue_events GET    /venues/:venue_id/events(.:format)       events#index
#                   venues GET    /venues(.:format)                        venues#index
#                    venue GET    /venues/:id(.:format)                    venues#show
#              band_events GET    /bands/:band_id/events(.:format)         events#index
#                    bands GET    /bands(.:format)                         bands#index
#                     band GET    /bands/:id(.:format)                     bands#show
#          reserve_payment GET    /payments/:id/reserve(.:format)          payments#reserve
#                 payments GET    /payments(.:format)                      payments#index
#                  payment GET    /payments/:id(.:format)                  payments#show
#                          DELETE /payments/:id(.:format)                  payments#destroy
#                     root        /                                        static#show
#                          GET    /static(/:permalink)(.:format)           static#show
#              rails_admin        /admin                                   RailsAdmin::Engine
#         new_user_session GET    /users/sign_in(.:format)                 devise/sessions#new
#             user_session POST   /users/sign_in(.:format)                 devise/sessions#create
#     destroy_user_session DELETE /users/sign_out(.:format)                devise/sessions#destroy
#            user_password POST   /users/password(.:format)                devise/passwords#create
#        new_user_password GET    /users/password/new(.:format)            devise/passwords#new
#       edit_user_password GET    /users/password/edit(.:format)           devise/passwords#edit
#                          PUT    /users/password(.:format)                devise/passwords#update
# cancel_user_registration GET    /users/cancel(.:format)                  devise/registrations#cancel
#        user_registration POST   /users(.:format)                         devise/registrations#create
#    new_user_registration GET    /users/sign_up(.:format)                 devise/registrations#new
#   edit_user_registration GET    /users/edit(.:format)                    devise/registrations#edit
#                          PUT    /users(.:format)                         devise/registrations#update
#                          DELETE /users(.:format)                         devise/registrations#destroy
# 
# Routes for RailsAdmin::Engine:
#     dashboard GET         /                                      rails_admin/main#dashboard
#         index GET|POST    /:model_name(.:format)                 rails_admin/main#index
#           new GET|POST    /:model_name/new(.:format)             rails_admin/main#new
#        export GET|POST    /:model_name/export(.:format)          rails_admin/main#export
#   bulk_delete POST|DELETE /:model_name/bulk_delete(.:format)     rails_admin/main#bulk_delete
# history_index GET         /:model_name/history(.:format)         rails_admin/main#history_index
#   bulk_action POST        /:model_name/bulk_action(.:format)     rails_admin/main#bulk_action
#          show GET         /:model_name/:id(.:format)             rails_admin/main#show
#          edit GET|PUT     /:model_name/:id/edit(.:format)        rails_admin/main#edit
#        delete GET|DELETE  /:model_name/:id/delete(.:format)      rails_admin/main#delete
#  history_show GET         /:model_name/:id/history(.:format)     rails_admin/main#history_show
#   show_in_app GET         /:model_name/:id/show_in_app(.:format) rails_admin/main#show_in_app
