class Musevent.Module
  helpers: undefined
  initialize: ()->
    if @helpers
      Musevent.initHelpers @helpers
    this

