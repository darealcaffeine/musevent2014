class Musevent.Views.SignUp extends Musevent.ModalView
  template: JST['users/sign_up']
  modelBinder: undefined
  initParent: ()->
    @options.parent = Context.ActiveRouters.ContentRouter.root()
  binding:
    email: '#user_email'
    password: '#user_password'
    password_confirmation: '#user_password_confirmation'

  viewEvents:
    'submit form': 'submit'
  initialize: ()->
    @modelBinder = new Backbone.ModelBinder()
    super
  render: ()->
    @$el.html @template(user: @model)
    @modelBinder.bind @model, @el, @binding
    super

  submit: ()->
    @model.signUp
      error: ()->
        _.each arguments, (arg)->
          console.log arg
      success: ()->
        Backbone.history.navigate '/'
        window.location.reload()
    false