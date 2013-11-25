class window.App.DocumentsAfterHandOverController extends Spine.Controller

  constructor: ->
    super
    do @setupModal
    do @printContract

  setupModal: =>
    tmpl = App.Render "manage/views/users/hand_over_documents_dialog", {contract: @contract, itemsCount: @itemsCount}
    modal = new App.Modal tmpl
    modal.undestroyable()
    @el = modal.el

  printContract: =>
    if App.InventoryPool.current.print_contracts
      window.open @contract.url() + "?print=true"
