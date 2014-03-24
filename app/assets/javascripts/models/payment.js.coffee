class Musevent.Models.Payment extends Backbone.Model
  defaults:
    processor_type: 'DummyProcessor'
  urlRoot: '/payments'
  typeName: 'Payment'
  url: ()->
    res = ''
    if @get('id')
      res = @urlRoot + '/' + @get('id') + '.json'
    else
      res = "/events/#{@get 'event_id'}/payments.json"
    res