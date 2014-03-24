class Musevent.ModalView extends Musevent.View
  getCachedRouteCallback: ()->
    view = this
    @cachedRouteCallback = ()->
      Backbone.history.off 'route', view.cachedRouteCallback
      view.$el.modal 'hide'
  baseEvents:
    'click a.next': 'showNextItem'
    'click a.prev': 'showPrevItem'
  showNextItem: ()->
    if @model.collection
      collection = @model.collection
      nextId = collection.indexOf(@model) + 1
      if nextId < collection.length
        nextModel = collection.at nextId
        nextView = Context.ActiveRouters.ModalsRouter["show_#{@model.typeName.toLowerCase()}"] nextModel
        nextView.options.parent = @options.parent
    false

  showPrevItem: ()->
    if @model.collection
      collection = @model.collection
      prevId = collection.indexOf(@model) - 1
      if prevId >= 0
        prevModel = collection.at prevId
        prevView = Context.ActiveRouters.ModalsRouter["show_#{@model.typeName.toLowerCase()}"] prevModel
        prevView.options.parent = @options.parent
    false

  events: ()->
    _.extend {}, @baseEvents, @viewEvents

  returnFromModal: (modalView)->
    # remove self from cache (last item)
    Musevent.Cache.Modals.pop()
    @isCached = false
    if @historyUrl
      Backbone.history.navigate @historyUrl
    Context.ActiveRouters.ModalsRouter.swap(this)

  leave: (skipParent)->
    @$el.remove()
    @options.parent.returnFromModal(this) if @options.parent and !skipParent
    super
  initParent: ()->
    false
  initialize: ()->
    @options.parent = Context.ActiveRouters.ContentRouter.currentView || @initParent()
    $el = @$el
    view = this
    $el.attr 'class', 'modal'
    super
  render: ()->
    if @historyUrl
      Backbone.history.navigate @historyUrl
    Backbone.history.on 'route', @getCachedRouteCallback()
    this