###

  Item

###

class window.App.Item extends Spine.Model

  @configure "Item", "id", "inventory_code", "serial_number", "is_broken", "is_incomplete", "is_borrowable", "model_id", "current_location", "properties", "retired"
  @belongsTo "location", "App.Location", "location_id"
  @belongsTo "model", "App.Model", "model_id"
  @hasOne "currentLocation", "App.CurrentItemLocation", "id"
  @hasMany "children", "App.Item", "parent_id"
  @belongsTo "parent", "App.Item", "parent_id"

  @extend Spine.Model.Ajax

  hasProblems: -> @is_broken or @is_incomplete or not @is_borrowable

  getProblems: =>
    problems = []
    problems.push _jed("Broken") if @is_broken
    problems.push _jed("Incomplete") if @is_incomplete
    problems.push _jed("Retired") if @retired
    problems.push _jed("Unborrowable") unless @is_borrowable
    problems.join(", ")

  currentLocation: =>
    if App.CurrentItemLocation.exists(@id)?
      App.CurrentItemLocation.find(@id).location
