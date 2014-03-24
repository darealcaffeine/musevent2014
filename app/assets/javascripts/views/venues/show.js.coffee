class Musevent.Views.ShowVenue extends Musevent.ModalView
  template: JST['venues/show']
  initParent: ()->
    @options.parent = Context.ActiveRouters.ContentRouter.venues_list()
  viewEvents:
    'click a.show-events': 'show_events'
  show_events: ()->
    @options.parent = Context.ActiveRouters.ContentRouter.venue_events @model.get 'id'
    @$el.modal 'hide'
    false
  initialize: ()->
    @historyUrl = "venues/#{@model.get 'id'}"
    super
  render: ()->
    @$el.html @template(venue: @model)
    super