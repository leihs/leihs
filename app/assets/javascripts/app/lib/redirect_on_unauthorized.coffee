###

  Redirect on unauthorized

  redirect the browser when a ajax request returns an error (401 / unauthorized)
  
###

jQuery ->
  $(document).on "ajaxError", (e, xhr)->
    window.location = "/" if xhr.status is 401