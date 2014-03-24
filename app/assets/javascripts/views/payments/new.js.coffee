class Musevent.Views.NewPayment extends Musevent.ModalView
  template: JST['payments/new']
  modelBinder: undefined
  historyUrl: undefined
  binding:
    {
    tickets_count: 'input[name=tickets_count]'
    processor_type: 'select[name=processor_type]'
    }
  viewEvents:
    {
    'click a.submit_payment': 'savePayment'
    'submit form': 'savePayment'
    }
  savePayment: ()->
    @model.save {},
      success: @savedSuccessfully
    false
  savedSuccessfully: (model)->
    window.location = model.get 'authorization_url'

  initialize: ()->
    @historyUrl = "events/#{@model.get 'event_id'}/payments/new"
    @modelBinder = new Backbone.ModelBinder()
    super
  render: ()->
    @$el.html @template()
    @modelBinder.bind @model, @el, @binding
    super