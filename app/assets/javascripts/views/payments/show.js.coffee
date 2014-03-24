class Musevent.Views.ShowPayment extends Musevent.ModalView
  template: JST['payments/show']
  initParent: ()->
    @options.parent = Context.ActiveRouters.ContentRouter.own_payments_list()
  initialize: ()->
    @historyUrl = "payments/#{@model.get 'id'}"
    super
  render: ()->
    @$el.html @template(payment: @model)
    super
