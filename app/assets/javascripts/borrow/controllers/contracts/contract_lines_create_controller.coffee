class window.App.ContractLinesCreateController extends window.App.ContractLinesChangeController

  # @override
  getAvailability: (inventoryPool)=> @availabilities[inventoryPool.id]

  # @override
  setupQuantity: -> true

  # @override
  selectFirstInventoryPool: ->
    inventoryPoolIds = App.ModelsIndexIpSelectorController.activeInventoryPoolIds
    for id in inventoryPoolIds
      option = @inventoryPoolSelect.find "option[data-id='#{id}']"
      if option.length
        option.prop "selected", true
        break

  # @override
  setupDates: =>
    if sessionStorage.startDate?
      @startDateEl.val sessionStorage.startDate
    else
      @startDateEl.val moment().format("YYYY-MM-DD")
    if sessionStorage.endDate?
      @endDateEl.val sessionStorage.endDate
    else
      @endDateEl.val moment().add("days", 1).format("YYYY-MM-DD")

  # @override
  store: => 
    quantity = @quantityEl.val()
    finish = _.after quantity, @done
    for time in [1..quantity]
      @createContractLine().done (datum) =>
        contractLine = App.ContractLine.find datum.id
        if App.Contract.exists(contractLine.contract_id)?
          do finish
        else
          App.Contract.ajaxFetch
            data: $.param
              ids: [contractLine.contract_id]
          .done (data)=>
            contract = App.Contract.find data[0].id
            App.Contract.currents.push contract unless _.find App.Contract.currents, (c) -> c.id is contract.id
            do finish