class Musevent.ContentView extends Musevent.View
  returnFromModal: (modalView)->
    Backbone.history.navigate(@historyUrl, false) if @historyUrl != undefined
    # clear modals cache
    Musevent.Cache.Modals.each (modal)->
      modal.leave(true) if _.isFunction modal.leave
    Musevent.Cache.Modals = _({})