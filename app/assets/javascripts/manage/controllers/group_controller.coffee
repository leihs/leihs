class window.App.GroupController extends Spine.Controller

  constructor: ->
    super
    new App.GroupPartitionsController {el: @el.find("#models-allocations"), removeHandler: @removePartitionHandler}
    new App.ManageUsersViaAutocompleteController {el: @el.find("#users"), removeHandler: @removeUserHandler}

  @removeHandler: (e) =>
    e.preventDefault()
    $(e.currentTarget).closest(".line").remove()

  removeUserHandler: @removeHandler

  removePartitionHandler: @removeHandler
