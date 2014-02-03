class window.App.ContractsUnapproveController extends Spine.Controller

  events:
    "click [data-order-unapprove]": "unapprove"

  unapprove: (e)=>
    trigger = $ e.currentTarget
    App.Button.disable trigger
    order = @order ? App.Contract.findOrBuild trigger.closest("[data-id]").data()
    done = @done ? =>
      line = trigger.closest(".line")
      line.html App.Render "manage/views/contracts/line_submitted", order, { accessRight: App.AccessRight, currentUserRole: App.User.current.role } if line?
    fail = @fail ? (response) =>
      line = trigger.closest(".line")
      App.Flash
        type: "error"
        message: response.responseText
      App.Button.enable trigger
    order.unapprove().done(done).fail(fail)
