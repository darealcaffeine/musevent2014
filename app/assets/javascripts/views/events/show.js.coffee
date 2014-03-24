class Musevent.Views.ShowEvent extends Musevent.ModalView
  template: JST['events/show']
  initParent: ()->
    @options.parent = Context.ActiveRouters.ContentRouter.events_list()
  initialize: ()->
    @historyUrl = "events/#{@model.get 'id'}"
    super
  render: ()->
    @$el.html @template(event: @model)
    super

  viewEvents:
    'click a.show-band': 'show_band'
    'click a.show-venue': 'show_venue'
    'click a.new-payment': 'new_payment'

  show_band: ()->
    bandView = Context.ActiveRouters.ModalsRouter.show_band @model.get 'band_id'
    bandView.options.parent = this
    false
  show_venue: ()->
    venue_view = Context.ActiveRouters.ModalsRouter.show_venue @model.get 'venue_id'
    venue_view.options.parent = this
    false
  new_payment: ()->
    payment_view = Context.ActiveRouters.ModalsRouter.new_payment @model.get 'id'
    payment_view.options.parent = this
    false