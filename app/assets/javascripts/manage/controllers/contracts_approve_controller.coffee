class window.App.ContractsApproveController extends Spine.Controller

  events: 
    "click [data-order-approve]": "approve"

  approve: (e)=>
    trigger = $ e.currentTarget
    line = trigger.closest(".line")
    App.Button.disable trigger
    order = @order ? App.Contract.findOrBuild line.data()
    done = @done ? =>
      line.html App.Render "manage/views/contracts/line_approved", order
    fail = @fail ? (response)=>
      new App.ContractsApproveFailedController {order: order, line: line, trigger: trigger, error: response.responseText}
      App.Button.enable trigger
    comment = if @comment?
      if typeof @comment == "function"
        @comment()
      else 
        @comment
    order.approve(comment).done(done).fail(fail)
