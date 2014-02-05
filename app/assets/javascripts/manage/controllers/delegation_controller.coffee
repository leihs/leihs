class window.App.DelegationController extends Spine.Controller

  constructor: ->
    super
    new App.ManageUsersViaAutocompleteController {el: @el.find("#users"), removeHandler: @removeUserHandler, paramName: "user[users][][id]"}

  @removeHandler: (e) =>
    e.preventDefault()
    $(e.currentTarget).closest(".line").remove()

  removeUserHandler: @removeHandler
