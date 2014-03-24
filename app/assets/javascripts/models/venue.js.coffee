class Musevent.Models.Venue extends Backbone.Model
  typeName: 'Venue'
  baseUrl: '/venues'
  url: ()->
    @baseUrl + '/' + @get('id') + '.json'