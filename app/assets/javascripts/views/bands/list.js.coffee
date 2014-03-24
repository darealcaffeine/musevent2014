class Musevent.Views.ListBands extends Musevent.ContentView
  template: JST['bands/list']
  historyUrl: 'bands'
  render: ()->
    view = this
    @$el.html @template(bands: @collection)
    $childrenContainer = @$('.bands')
    if $childrenContainer
      @collection.each (band)->
        child = new Musevent.Views.ListItemBand(model: band)
        view.appendChildTo child, $childrenContainer
    this

