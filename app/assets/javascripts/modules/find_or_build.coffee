window.App.Modules.FindOrBuild = 

  findOrBuild: (data)->
    if data.type == "take_back" or data.type == "hand_over"
      # NOTE we really want the subclass of Visit
      record = @exists data
    else
      record = @exists data.id

    record = new @(data) unless record
    return record
