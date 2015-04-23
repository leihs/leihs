class window.App.ContractsApproveController extends Spine.Controller

  events: 
    "click [data-order-approve]": "approve"

  approve: (e)=>
    trigger = $ e.currentTarget
    App.Button.disable trigger
    order = @order ? App.Contract.findOrBuild trigger.closest("[data-id]").data()
    done = @done ? =>
      line = trigger.closest(".line")
      line.html App.Render "manage/views/contracts/line_approved", order, { accessRight: App.AccessRight, currentUserRole: App.User.current.role } if line?
    fail = @fail ? (response)=>
      callback = =>
        line = trigger.closest(".line")
        new App.ContractsApproveFailedController {order: order, line: line, trigger: trigger, error: response.responseText, done: @done}
        App.Button.enable trigger
      @fetchData order, callback
    comment = if @comment?
      if typeof @comment == "function"
        @comment()
      else 
        @comment
    order.approve(comment).done(done).fail(fail)

  fetchData: (record, callback)=>
    modelIds = []
    optionIds = []
    for line in record.reservations().all()
      if line.model_id?
        modelIds.push(line.model_id) unless App.Model.exists(line.model_id)?
      else if line.option_id?
        optionIds.push(line.option_id) unless App.Option.exists(line.option_id)?
    @fetchModels(modelIds).done => @fetchOptions(optionIds).done => do callback

  fetchModels: (ids)=>
    if ids.length
      App.Model.ajaxFetch
        data: $.param
          ids: ids
    else
      {done: (c)->c()}

  fetchOptions: (ids)=>
    if ids.length
      App.Option.ajaxFetch
        data: $.param
          ids: ids
    else
      {done: (c)->c()}
