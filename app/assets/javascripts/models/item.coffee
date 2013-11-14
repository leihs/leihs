###
  
  Item

###

class window.App.Item extends Spine.Model

  @configure "Item", "id", "inventory_code", "is_broken", "is_incomplete", "is_borrowable", "model_id", "current_location"
  @belongsTo "location", "App.Location", "location_id"
  @belongsTo "model", "App.Model", "model_id"
  @hasOne "currentLocation", "App.CurrentItemLocation", "id"
  @hasMany "children", "App.Item", "parent_id"

  @extend Spine.Model.Ajax

  hasProblems: -> @is_broken or @is_incomplete or not @is_borrowable

  getProblems: =>
    problems = []
    problems.push _jed("Broken") if @is_broken
    problems.push _jed("Incomplete") if @is_incomplete
    problems.join(", ")

  currentLocation: =>
    if App.CurrentItemLocation.exists(@id)?
      App.CurrentItemLocation.find(@id).location
