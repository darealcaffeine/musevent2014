class Musevent.Views.ListItemVenue extends Support.CompositeView
  template: JST['venues/list_item']
  className: "venue stacked-item"
  viewEvents:
    'click a.show-venue': 'show_venue'
    'click a.show-events': 'show_events'
  show_events: ()->
    Context.ActiveRouters.ContentRouter.venue_events @model.get 'id'
    false
  show_venue: ()->
    view = Context.ActiveRouters.ModalsRouter.show_venue @model.get 'id'
    view.options.parent = @parent
    false
  setElParams: ()->
    @$el.attr 'id', "venue_#{@model.get 'id'}"
  render: ()->
    @setElParams()
    @$el.html @template(venue: @model)
    this