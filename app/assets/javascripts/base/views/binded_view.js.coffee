# Override _modelBindings if you want custom bindings.
# Refer to https://github.com/theironcook/Backbone.ModelBinder for more info.
# Don't forget to call super in initialize() and render()
class Musevent.BindedView extends Musevent.View
  _modelBinder: undefined
  _modelBindings: undefined
  initialize: ()->
    @_modelBinder = new Backbone.ModelBinder()
    super
  render: ()->
    @_modelBinder.bind @model, @el, @_modelBindings
    super
