class Musevent.Router extends Backbone.Router
  swap: (newView)->
    newView.render().$el.hide()
    cv = Context.currentView
    cv?.hide ()->
      cv.$el.detach()
    newView.$el.appendTo Context.$contentEl
    newView.show()
    Context.currentView = newView