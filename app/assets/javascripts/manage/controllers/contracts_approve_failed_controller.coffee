class window.App.ContractsApproveFailedController extends Spine.Controller

  elements: 
    "#comment": "commentEl"

  events: 
    "click [data-approve-anyway]": "approveAnyway"

  constructor: (options)->
    @trigger = $(options.trigger)
    @order = options.order
    @order.error = options.error
    tmpl = App.Render "manage/views/contracts/approval_failed_modal", @order,
      comment: options.comment
      accessRight: App.AccessRight
      currentUserRole: App.User.current.role
    @modal = new App.Modal(tmpl)
    @el = @modal.el
    super

  approveAnyway: => 
    comment = if @commentEl.val().length then @commentEl.val()
    @modal.destroy(false)
    @modal.undestroyable()
    @order.approve_anyway(comment).done =>
      @modal.destroyable().destroy true
      if @done
        do @done
      else
        @line.html App.Render "manage/views/contracts/line_approved", @order, { accessRight: App.AccessRight, currentUserRole: App.User.current.role }
