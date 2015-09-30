window.App.Modules.FindOrBuild = 

  findOrBuild: (data)->
    record = @exists data.id

    if record
      _.each Object.keys(data), (key)=>
        unless record[key]
          record[key] = data[key]
    else
      record = new @(data)

    return record
