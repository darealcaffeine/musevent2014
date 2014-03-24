class Musevent.Views.ListEvents extends Musevent.ContentView
  template: JST['events/list']
  historyUrl: 'events'
  render: ()->
    view = this
    @$el.html @template(events: @collection, title: @options.title)
    $childrenContainer = @$('.events')
    if $childrenContainer
      @collection.each (event)->
        child = new Musevent.Views.ListItemEvent(model: event)
        view.appendChildTo child, $childrenContainer
    this

