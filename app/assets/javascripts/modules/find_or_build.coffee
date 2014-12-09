window.App.Modules.FindOrBuild = 

  findOrBuild: (data)->
    record = @exists data.id
    record = new @(data) unless record
    return record
