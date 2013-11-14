###
  
  Location

###

class window.App.Location extends Spine.Model

  @configure "Location", "id", "room", "shelf", "building_id"
  @belongsTo "building", "App.Building", "building_id"

  @extend Spine.Model.Ajax