class Musevent.Collections.Events extends Backbone.Collection
  model: Musevent.Models.Event
  baseUrl: '/events.json'
  filter: undefined
  url: ()->
    res = @baseUrl
    params = _.map @filter, (val, key)-> "#{key}=#{val}"
    res = "#{res}?#{params.join '&'}" if params.length
    res
  initialize: ()->
    @filter = {}