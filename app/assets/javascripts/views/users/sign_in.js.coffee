class Musevent.Views.SignIn extends Musevent.ModalView
  template: JST['users/sign_in']
  modelBinder: undefined
  initParent: ()->
    @options.parent = Context.ActiveRouters.ContentRouter.root()
  binding:
    email: '#user_email'
    password: '#user_password'
    remember_me: '#user_remember_me'

  viewEvents:
    'submit form#new_user': 'submit'

  initialize: ()->
    @modelBinder = new Backbone.ModelBinder()
    super
  render: ()->
    @$el.html @template(user: @model)
    @modelBinder.bind @model, @el, @binding
    super

  submit: ()->
    console.log 'form submitted'
    @model.signIn
      success: ()->
        Backbone.history.navigate '/'
        window.location.reload()
    false