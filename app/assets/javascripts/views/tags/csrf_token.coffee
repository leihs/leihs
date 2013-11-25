 $.views.tags

  csrf_token: ->
    token = $('meta[name="csrf-token"]').attr('content')
    "<input type='hidden' name='authenticity_token' value='#{token}' />"

    