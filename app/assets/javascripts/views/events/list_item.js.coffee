class Musevent.Views.ListItemEvent extends Support.CompositeView
  template: JST['events/list_item']
  className: "event stacked-item"
  events:
    'click a.show-event': 'show_event'
    'click a.new-payment': 'new_payment'
  show_event: ()->
    event_view = Context.ActiveRouters.ModalsRouter.show_event @model
    event_view.options.parent = this.parent
    false
  new_payment: ()->
    payment_view = Context.ActiveRouters.ModalsRouter.new_payment @model.get 'id'
    payment_view.options.parent = @parent
    false
  setElParams: ()->
    @$el.attr 'id', "event_#{@model.get 'id'}"
  render: ()->
    @setElParams()
    @$el.html @template(event: @model)
    this