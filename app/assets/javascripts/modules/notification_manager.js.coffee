class Musevent.Modules.NotificationManager extends Musevent.Module
  _getMessageDisplayFunction: (type)->
    module = this
    (message)->
      module.container.notify(
        type: module.mappings[type]
        message:
          text: message
      ).show()
      true
  _init_create_helpers: ()->
    # Create helpers to show error messages
    # window.mse_error_message
    module = this
    @helpers = {}
    _.each ['error', 'info', 'success'], (type)->
      module.helpers["#{type}_message"] = module._getMessageDisplayFunction type
  _init_show_flash_messages: ()->
    # Show messages that server sent as flash[]
    module = this
    _.each Gon.notifications, (notification)->
      type = notification[0]
      message = notification[1]
      module.helpers["#{type}_message"] message

  initialize: ()->
    @container = $('#flash')
    @_init_create_helpers()
    @_init_show_flash_messages()
    super