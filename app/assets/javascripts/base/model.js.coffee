class Musevent.Model extends Backbone.Model
  @parse_html_id: (str)->
    str_num = str.split("_")[1]
    parseInt str_num, 10
  @error_handler: (model, xhr)->
    response = JSON.parse(xhr.responseText)
    if response.errors
      _.each response.errors, (messages, field)->
        _.each messages, (message)->
          mse_error_message "#{field} #{message}"
    else if response.error
      af_error_message response.error
  @_default_sync_options:
    error: @error_handler
  urlRoot: undefined
  param: undefined
  sync: (method, model, options)->
    if options['method']
      arguments[0] = options['method']
    super
  @prepare_sync_options: (args)->
    if arguments[0] instanceof Object
      options_index = 1
    else
      options_index = 2
    # override defaults, not vise-versa
    arguments[options_index] = _.extend _.clone(Musevent.Model._default_sync_options), arguments[options_index]
  fetch: ()->
    Musevent.Model.prepare_sync_options arguments
    super
  save: ()->
    Musevent.Model.prepare_sync_options arguments
    if _.isObject arguments[0]
      key = {}
      if _.isEmpty arguments[0]
        arguments[0] = _.clone @attributes
      key[@param] = arguments[0]
      arguments[0] = key
    super

  url: ()->
    url = @urlRoot
    url += '/' + @get 'id' unless @isNew()
    url + '.json'

  html_id: ()->
    unless @isNew()
      "#{@param}_#{@id}"
    else
      "new_#{@param}"