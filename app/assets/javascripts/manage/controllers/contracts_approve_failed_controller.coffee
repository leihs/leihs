class window.App.ContractsApproveFailedController extends Spine.Controller

  elements: 
    "#comment": "commentEl"

  events: 
    "click [data-approve-anyway]": "approveAnyway"

  constructor: (options)->
    @trigger = $(options.trigger)
    @order = options.order
    @order.error = options.error
    tmpl = App.Render "manage/views/contracts/approval_failed_modal", @order, {comment: options.comment}
    @modal = new App.Modal(tmpl)
    @el = @modal.el
    super

  approveAnyway: => 
    comment = if @commentEl.val().length then @commentEl.val()
    @order.approve_anyway comment
    @modal.destroy true