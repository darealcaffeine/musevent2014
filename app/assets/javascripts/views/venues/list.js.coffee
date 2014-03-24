class Musevent.Views.ListVenues extends Musevent.ContentView
  template: JST['venues/list']
  historyUrl: 'venues'
  render: ()->
    view = this
    @$el.html @template(venues: @collection)
    $childrenContainer = @$('.venues')
    if $childrenContainer
      @collection.each (venue)->
        child = new Musevent.Views.ListItemVenue(model: venue)
        view.appendChildTo child, $childrenContainer
    this

