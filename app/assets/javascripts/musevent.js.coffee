window.Context =
  ActiveRouters:
    {}
  ActiveModules:
    {}
  Cache:
    Modals: _({})
  ByCid:
    {}

window.Musevent =
  Constants:
    app_name: "Musevent"
    abbr_name: 'mse'
  Models:
    {}
  Collections:
    {}
  Cache: Context.Cache # Deprecated
  Views:
    {}
  Modules:
    {}
  Routers:
    {}
  Helpers:
    attributes_from: (hash)->
      optionStrings = _.map hash, (value, key)-> "#{key}='#{value}'"
      optionStrings.join ' '
    title: (value, content_tag)->
      content_tag ||= 'h1'
      $('title').text "#{value} | #{Musevent.Constants.app_name}"
      "<#{content_tag}>#{value}</#{content_tag}>"
    link_to: (text, path, options = {})->
      _.extend options, {href: path}
      "<a #{mse_attributes_from(options)}>#{text}</a>"
    current_user: ()->
      Context.current_user
  initHelpers: (helpers)->
    _.each helpers, (helper, name)->
      var_name = "#{Musevent.Constants.abbr_name}_#{name}"
      window[var_name] = helper
  initialize: ()->
    @initHelpers @Helpers

    _.each @Modules, (module, name)-> Context.ActiveModules[name] = (new module()).initialize()
    _.each @Routers, (router, name)-> Context.ActiveRouters[name] = new router()

    # Workaround for FB redirect adding '#_=_' to location
    window.location.hash = '' if (window.location.hash == '#_=_')
    Backbone.history.start pushState: true
  navigate: (url)->
    Backbone.history.navigate url, trigger: true

$(document).ready ->
  Musevent.initialize()