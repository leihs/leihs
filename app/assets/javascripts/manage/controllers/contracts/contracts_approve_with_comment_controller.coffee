class window.App.ContractsApproveWithCommentController extends Spine.Controller

  elements: 
    "#comment": "comment"

  constructor: (options)->
    @trigger = options.trigger
    @contract = options.contract
    tmpl = App.Render "manage/views/contracts/approve_with_comment_modal", @contract
    @modal = new App.Modal(tmpl)
    @el = @modal.el
    super
    new App.ContractsApproveController {el: @el, done: @approved, comment: => @comment.val()}

  approved: =>
    window.location = "/manage/#{App.InventoryPool.current.id}/daily?flash[success]=#{_jed('Order approved')}"
