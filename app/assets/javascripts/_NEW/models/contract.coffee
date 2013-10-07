###
  
  Contract

###

class window.App.Contract extends Spine.Model

  @configure "Contract", "id", "user_id", "inventory_pool_id", "status", "purpose"

  @hasMany "lines", "App.ContractLine", "contract_id"

  isAvailable: => _.all @.lines().all(), (line) -> line["available?"]
