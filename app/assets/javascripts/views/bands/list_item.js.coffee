class Musevent.Views.ListItemBand extends Support.CompositeView
  template: JST['bands/list_item']
  className: "band stacked-item"
  events:
    'click a.show-band': 'show_band'
    'click a.show-events': 'show_events'
  show_events: ()->
    Context.ActiveRouters.ContentRouter.band_events @model.get 'id'
    false
  show_band: ()->
    bandView = Context.ActiveRouters.ModalsRouter.show_band @model.get 'id'
    bandView.options.parent = this.parent
    false
  setElParams: ()->
    @$el.attr 'id', "band_#{@model.get 'id'}"
  render: ()->
    @setElParams()
    @$el.html @template(band: @model)
    this