class Musevent.Models.User extends Backbone.Model
  userType: undefined
  url: ()->
    "/users/#{@get 'id'}"
  typeName: "User"
  defaults:
    remember_me: true

  signUp: (options)->
    options ||= {}
    data =
      'user[email]': @get 'email'
      'user[password]': @get 'password'
      'user[password_confirmation]': @get 'password_confirmation'
    jqXHR = $.ajax '/users.json',
      data: data,
      type: 'POST'
      error: options.error
      success: options.success
    jqXHR

  signIn: (options)->
    options ||= {}
    data =
      'user[email]': @get 'email'
      'user[password]': @get 'password'
      'user[remember_me]': @get 'remember_me'
    jqXHR = $.ajax '/users/sign_in.json',
      data: data
      type: 'POST'
      error: options.error
      success: options.success
    jqXHR
