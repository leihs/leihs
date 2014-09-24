class window.App.UserController extends Spine.Controller

  constructor: ->
    super
    new App.ChangeUserGroupsController {el: @el.find("#change-groups")}
    new App.UserSuspendedUntilController {el: @el}
