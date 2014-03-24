class Musevent.Views.ShowBand extends Musevent.ModalView
  template: JST['bands/show']
  initParent: ()->
    @options.parent = Context.ActiveRouters.ContentRouter.bands_list()
  viewEvents:
    'click a.show-events': 'show_events'
  show_events: ()->
    @options.parent = Context.ActiveRouters.ContentRouter.band_events @model.get 'id'
    @$el.modal 'hide'
    false
  initialize: ()->
    @historyUrl = "bands/#{@model.get 'id'}"
    super
  render: ()->
    @$el.html @template(band: @model)
    super
