###

  Availability
  
###

class Availability

  @changes

  constructor: (changes)->
    @changes = changes
    
  #maximumAvailable: (user, start_date, end_date) =>
    #user_group_ids = _.map user.groups, (g)-> g.id

  #getChanges: (start_date, end_date) =>
    #_.filter @changes, (c) -> moment(c[0]).sod()
    
  #mostRecentChange: =>
  
window.App.Availability = Availability