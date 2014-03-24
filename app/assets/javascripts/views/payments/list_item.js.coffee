class Musevent.Views.ListItemPayment extends Support.CompositeView
  template: JST['payments/list_item']
  defaultClass: "payment"
  tagName: 'tr'
  events:
    'click a.show-payment': 'show_payment'
  show_payment: ()->
    payment_view = Context.ActiveRouters.ModalsRouter.show_payment @model.get 'id'
    payment_view.options.parent = this.parent
    false
  setElParams: ()->
    @$el.attr 'id', "payment_#{@model.get 'id'}"
  render: ()->
    @setElParams()
    @$el.html @template(payment: @model)
    this