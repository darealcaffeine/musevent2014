class Musevent.View extends Support.CompositeView
  show: (cb)->
    @$el.slideDown cb
  hide: (cb)->
    @$el.slideUp cb
  render: -> this
