class window.App.HandOverDialogController extends Spine.Controller

  events:
    "click [data-hand-over]": "handOver"

  elements:
    "#purpose": "purposeTextArea"
    "#note": "noteTextArea"
    "#error": "errorContainer"

  constructor: (options)->
    @user = options.user
    @lines = (App.ContractLine.find id for id in App.LineSelectionController.selected)
    @purpose = (_.uniq _.map @lines, (l)->l.purpose().description).join ", "
    if @validateDialog()
      do @setupModal
      @searchSetUserController = new App.SearchSetUserController
        el: @el.find("#contact-person")
        additionalSearchParams: { delegation_id: @user.id }
      super
      do @autoFocus
    else
      return false

  autoFocus: =>
    if @purposeTextArea.length
      @purposeTextArea.focus()
    else
      @noteTextArea.focus()

  validateDialog: =>
    do @validateStartDate and do @validateEndDate and do @validateAssignment

  validateStartDate: =>
    if _.any(@lines, (l)-> moment(l.start_date).endOf("day").diff(moment().startOf("day"), "days") > 0)
      App.Flash
        type: "error"
        message: _jed "you cannot hand out lines which are starting in the future"
      return false
    return true

  validateEndDate: =>
    if _.any(@lines, (l)-> moment(l.end_date).endOf("day").diff(moment().startOf("day"), "days") < 0)
      App.Flash
        type: "error"
        message: _jed "you cannot hand out lines which are ending in the past"
      return false
    return true

  validateAssignment: =>
    if(_.any @lines, (l) -> (l.item_id == null and l.option_id == null))
      App.Flash
        type: "error"
        message: _jed "you cannot hand out lines with unassigned inventory codes"
      return false
    return true

  setupModal: =>
    lines = _.map @lines, (line)->
      line.start_date = moment().format("YYYY-MM-DD")
      line
    @itemsCount = _.reduce lines, ((mem,l)-> l.quantity + mem), 0
    data = 
      groupedLines: App.Modules.HasLines.groupByDateRange lines, true
      user: @user
      itemsCount: @itemsCount
      purpose: @purpose
    tmpl = $ App.Render "manage/views/users/hand_over_dialog", data, {showAddPurpose: _.any(@lines, (l)-> not l.purpose_id?)}
    tmpl.find("#add-purpose").on "click", (e)=> $(e.currentTarget).remove() and tmpl.find("#purpose-input").removeClass "hidden"
    @modal = new App.Modal tmpl
    @el = @modal.el

  handOver: =>
    @purpose = @purposeTextArea.val() unless @purpose.length
    if @validatePurpose()
      @contract.sign
        line_ids: _.map(@lines, (l)->l.id)
        purpose: @purposeTextArea.val()
        note: @noteTextArea.val()
      .fail (e)=>
        @errorContainer.find("strong").html(e.responseText)
        @errorContainer.removeClass("hidden")
      .done =>
        @modal.undestroyable()
        @modal.el.detach()
        new App.DocumentsAfterHandOverController
          contract: @contract
          itemsCount: @itemsCount

  validatePurpose: => 
    unless @purpose.length
      @errorContainer.find("strong").html(_jed("Specification of the purpose is required"))
      @errorContainer.removeClass("hidden")
      @purposeTextArea.focus()
      return false
    return true

  toggleAddPurpose: =>

  validateDelegatedUser: =>
    if @contract.user().isDelegation() and not @contract.delegatedUser()
      @errorContainer.find("strong").html(_jed("Specification of the contact person is required"))
      @errorContainer.removeClass("hidden")
      @searchSetUserController.input.focus()
      false
    else
      true
