class Musevent.Routers.ModalsRouter extends Backbone.Router
  currentView: undefined
  swap: (newView)->
    router = this
    if @currentView
      Musevent.Cache.Modals.push @currentView
      @currentView.isCached = true
      @currentView.$el.modal 'hide'
    newView.render().$el.modal 'show'
    newView.$el.on 'hidden', ()->
      unless newView.isCached
        newView.leave() if _.isFunction newView.leave
      router.currentView = undefined if router.currentView == newView
    @currentView = newView
    @currentView

  routes:
    'events/:id': 'show_event'
    'bands/:id': 'show_band'
    'venues/:id': 'show_venue'
    'payments/:id': 'show_payment'
    'users/sign_in': 'sign_in'
    'users/sign_up': 'sign_up'
    'events/:id/payments/new': 'new_payment'

  show_event: (id)->
    router = this
    if id instanceof Musevent.Models.Event
      event = id
    else
      event = new Musevent.Models.Event id: id

    view = new Musevent.Views.ShowEvent model: event
    event.fetch success: ()->
      router.swap view
    view

  show_band: (id)->
    router = this
    band = new Musevent.Models.Band id: id
    view = new Musevent.Views.ShowBand model: band
    band.fetch success: ()->
      router.swap view
    view

  sign_in: ()->
    router = this
    user = new Musevent.Models.User()
    view = new Musevent.Views.SignIn(model: user)
    setTimeout ()->
      router.swap(view)
    , 100
    view

  sign_up: ()->
    router = this
    user = new Musevent.Models.User()
    view = new Musevent.Views.SignUp(model: user)
    setTimeout ()->
      router.swap(view)
    , 100
    view

  show_payment: (id)->
    router = this
    payment = new Musevent.Models.Payment id: id
    view = new Musevent.Views.ShowPayment model: payment
    payment.fetch success: ()->
      router.swap view
    view

  show_venue: (id)->
    router = this
    venue = new Musevent.Models.Venue id: id
    view = new Musevent.Views.ShowVenue model: venue
    venue.fetch success: ()->
      router.swap view
    view

  new_payment: (event_id)->
    payment = new Musevent.Models.Payment(event_id: event_id)
    view = new Musevent.Views.NewPayment(model: payment)
    @swap view
    view

# TODO: Hide opened modal if we opened something new in content window
###
Backbone.history.on 'route', (router)->
  if router != Router and routercurrentView
    routercurrentView.$el.modal 'hide'###
