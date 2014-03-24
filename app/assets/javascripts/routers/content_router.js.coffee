class Musevent.Routers.ContentRouter extends Support.SwappingRouter
  el: $('.content')

  swap: (newView)->
    $('.loader').show()
    $newEl = newView.render().$el
    cv = @currentView
    @currentView = newView
    $newEl.hide()
    $(@el).append $newEl
    if cv
      cv.$el.hide 'slide', {direction: 'left'}, 500, ()->
        $newEl.show 'slide', {direction: 'right'}, 500, ()->
          $('.loader').hide()
        cv.leave() if _.isFunction cv.leave
    else
      $newEl.show 'slide', {direction: 'right'}, 500, ()->
        $('.loader').hide()
  routes:
    'payments': 'own_payments_list'
    'events': 'events_list'
    'bands': 'bands_list'
    'venues': 'venues_list'
    '': 'root'
    'payments/:id/reserve': 'payment_reserved'
    'bands/:id/events': 'band_events'
    'venues/:id/events': 'venue_events'

  band_events: (id)->
    router = this
    events = new Musevent.Collections.Events
    events.filter = band_id: id
    view = new Musevent.Views.ListEvents collection: events
    events.fetch success: ()->
      view.options.title = "Events for #{events.first().get 'band_title'}" if events.length
      router.swap view
    view

  venue_events: (id)->
    router = this
    events = new Musevent.Collections.Events
    events.filter = venue_id: id
    view = new Musevent.Views.ListEvents collection: events
    events.fetch success: ()->
      view.options.title = "Events for #{events.first().get 'venue_title'}" if events.length
      router.swap view
    view

  own_payments_list: ()->
    router = this
    payments = new Musevent.Collections.MyPayments()
    view = new Musevent.Views.ListPayments collection: payments
    payments.fetch success: ()->
      router.swap view
    view

  events_list: ()->
    router = this
    events = new Musevent.Collections.Events()
    view = new Musevent.Views.ListEvents collection: events
    events.fetch success: ()->
      router.swap view
    view

  bands_list: ()->
    router = this
    bands = new Musevent.Collections.Bands()
    view = new Musevent.Views.ListBands collection: bands
    bands.fetch success: ()->
      router.swap view
    view

  venues_list: ()->
    router = this
    venues = new Musevent.Collections.Venues()
    view = new Musevent.Views.ListVenues collection: venues
    venues.fetch success: ()->
      router.swap view
    view

  root: ()->
    view = new Musevent.Views.Root()
    @swap view
    view

  payment_reserved: (id)->
    router = this
    payment = new Musevent.Models.Payment(id: id)
    view = new Musevent.Views.ReservePayment(model: payment)
    payment.fetch success: ()->
      router.swap view
    view