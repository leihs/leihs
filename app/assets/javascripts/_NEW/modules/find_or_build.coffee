window.App.Modules.FindOrBuild = 

  find_or_build: (data)-> 
    record = @exists data.id
    record = new @(data) unless record
    return record