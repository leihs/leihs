class window.App.ContractsApproveController extends Spine.Controller

  events: 
    "click [data-order-approve]": "approve"

  approve: (e)=>
    trigger = $ e.currentTarget
    App.Button.disable trigger
    order = @order ? App.Contract.findOrBuild trigger.closest("[data-id]").data()
    done = @done ? =>
      line = trigger.closest(".line")
      line.html App.Render "manage/views/contracts/line_approved", order if line?
    fail = @fail ? (response)=>
      line = trigger.closest(".line")
      new App.ContractsApproveFailedController {order: order, line: line, trigger: trigger, error: response.responseText}
      App.Button.enable trigger
    comment = if @comment?
      if typeof @comment == "function"
        @comment()
      else 
        @comment
    order.approve(comment).done(done).fail(fail)
