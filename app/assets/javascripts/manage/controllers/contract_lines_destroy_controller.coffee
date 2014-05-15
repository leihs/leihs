class window.App.ContractLinesDestroyController extends Spine.Controller

  events: 
    "click [data-destroy-line]": "destroyLine"
    "click [data-destroy-lines]": "destroyLines"
    "click [data-destroy-selected-lines]": "destroySelectedLines"

  destroyLine: (e)=> @destroyContractLines $(e.currentTarget), [$(e.currentTarget).closest("[data-id]").data("id")]

  destroyLines: (e)=> @destroyContractLines $(e.currentTarget), $(e.currentTarget).data("ids")

  destroySelectedLines: (e)=> @destroyContractLines $(e.currentTarget), App.LineSelectionController.selected

  destroyContractLines: (trigger, ids) =>
    App.LineSelectionController.selected = _.difference App.LineSelectionController.selected, ids
    App.ContractLine.destroyMultiple ids
