class window.App.ContractsEditPurposeController extends Spine.Controller

  elements:
    "textarea": "textarea"
    "#errors": "errorsContainer"

  events:
    "submit form": "submit"

  constructor: (data)->
    @modal = new App.Modal App.Render "manage/views/contracts/edit/purpose_modal", data.purpose
    @el = @modal.el
    super

  delegateEvents: =>
    super

  submit: (e)->
    e.preventDefault()
    @purpose.description = _.string.clean @textarea.val()
    @errorsContainer.addClass "hidden"
    if @purpose.save()
      @modal.destroy true
    else
      @errorsContainer.removeClass "hidden"
      @errorsContainer.find("strong").text @purpose.validate()