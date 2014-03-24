class Musevent.Views.Root extends Musevent.ContentView
  template: JST['static/root']
  historyUrl: ''
  render: ()->
    @$el.html @template()
    this