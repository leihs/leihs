class window.App.TopBarController extends Spine.Controller

  events:
    "change #start_screen_checkbox": "changeStartScreen"

  elements:
    "#start_screen_checkbox": "startScreenCheckbox"

  changeStartScreen: =>
    path = window.location.pathname + window.location.search + window.location.hash
    if @startScreenCheckbox.is ":checked"
      App.User.current.setStartScreen path
    else
      App.User.current.setStartScreen null

  checkStartScreenState: =>
    path = window.location.pathname + window.location.search + window.location.hash
    if App.User.current.start_screen == path
      @startScreenCheckbox.prop "checked", true
    else
      @startScreenCheckbox.prop "checked", false