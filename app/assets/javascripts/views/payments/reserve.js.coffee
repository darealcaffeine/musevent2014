class Musevent.Views.ReservePayment extends Support.CompositeView
  template: JST['payments/reserve']
  render: ()->
    @$el.html @template(payment: @model)
    this