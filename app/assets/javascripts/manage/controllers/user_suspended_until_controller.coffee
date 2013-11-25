class window.App.UserSuspendedUntilController extends Spine.Controller

  elements:
    "input[data-suspended-until-input]": "input"
    "#suspended-reason": "suspendedReason"

  events:
    "change input[data-suspended-until-input]": "toggleSuspendedReason"

  constructor: ->
    super
    @input.datepicker()

  toggleSuspendedReason: =>
    if _.isEmpty @input.val() then @hideSuspendedReason() else @showSuspendedReason()

  showSuspendedReason: =>
    @suspendedReason.removeClass("hidden")

  hideSuspendedReason: =>
    @suspendedReason.addClass("hidden")
