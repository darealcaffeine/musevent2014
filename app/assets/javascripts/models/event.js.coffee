class Musevent.Models.Event extends Backbone.Model
  typeName: 'Event'
  baseUrl: '/events'
  url: ()->
    @baseUrl + '/' + @get('id') + '.json'