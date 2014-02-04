class window.App.DelegationController extends Spine.Controller

  constructor: ->
    super
    new App.ManageUsersViaAutocompleteController {el: @el.find("#users"), removeHandler: @removeUserHandler, paramName: "user[user_ids][]"}

  @removeHandler: (e) =>
    e.preventDefault()
    $(e.currentTarget).closest(".line").remove()

  removeUserHandler: @removeHandler
