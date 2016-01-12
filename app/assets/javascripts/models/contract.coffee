###
  
  Contract

###

class window.App.Contract extends Spine.Model

  @configure "Contract", "id", "user_id", "inventory_pool_id", "status", "delegated_user_id", "to_be_verified?"

  @extend Spine.Model.Ajax
  @extend App.Modules.FindOrBuild
  @include App.Modules.HasLines

  @belongsTo "user", "App.User", "user_id"
  @belongsTo "delegatedUser", "App.User", "delegated_user_id"
  @hasMany "reservations", "App.Reservation", "contract_id"

  @url: => "/contracts"

  to_be_verified: => this['to_be_verified?'] # hack around coffeescript's existantial operator

  isAvailable: => _.all @.reservations().all(), (line) -> line["available?"]

  quantity: =>
    _.reduce @.reservations().all(), ((mem, line) -> mem + line["quantity"]), 0

  concatenatedPurposes: =>
    (_.uniq _.map @.reservations().all(), (l)->l.purpose().description).join ", "
