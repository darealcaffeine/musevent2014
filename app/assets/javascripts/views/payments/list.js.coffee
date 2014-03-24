class Musevent.Views.ListPayments extends Musevent.ContentView
  template: JST['payments/list']
  historyUrl: 'payments'
  render: ()->
    view = this
    @$el.html @template(payments: @collection)
    $childrenContainer = @$('table.payments tbody')
    if $childrenContainer
      @collection.each (payment)->
        child = new Musevent.Views.ListItemPayment(model: payment)
        view.appendChildTo child, $childrenContainer
    this