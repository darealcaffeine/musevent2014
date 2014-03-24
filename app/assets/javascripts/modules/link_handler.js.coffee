class Musevent.Modules.LinkHandler extends Musevent.Module
  _handle: (e)->
    $link = $(e.currentTarget)
    e.stopPropagation()
    href = $link.attr 'href'
    Musevent.navigate href
    false

  initialize: ()->
    $(document).on 'click', 'a:not([rel=external])', @_handle
    this
