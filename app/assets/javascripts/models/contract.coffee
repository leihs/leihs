###
  
  Contract

###

class window.App.Contract extends Spine.Model

  @configure "Contract", "id", "user_id", "inventory_pool_id", "status_const", "delegated_user_id"

  @extend Spine.Model.Ajax
  @extend App.Modules.FindOrBuild
  @include App.Modules.HasLines

  @belongsTo "user", "App.User", "user_id"
  @belongsTo "delegatedUser", "App.User", "delegated_user_id"
  @hasMany "lines", "App.ContractLine", "contract_id"

  @url: => "/contracts"

  isAvailable: => _.all @.lines().all(), (line) -> line["available?"]

  quantity: =>
    _.reduce @.lines().all(), ((mem, line) -> mem + line["quantity"]), 0

  concatenatedPurposes: =>
    (_.uniq _.map @.lines().all(), (l)->l.purpose().description).join ", "
