class Musevent.Models.Band extends Backbone.Model
  typeName: 'Band'
  baseUrl: '/bands'
  url: ()->
    @baseUrl + '/' + @get('id') + '.json'