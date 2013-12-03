App.Modules.Rooted = 

  rooted: (data, entity)->
    if data[entity]?
      className = _.string.classify(entity)
      
      unless App[className].exists(data[entity].id)?
        App[className].addRecord new App[className] data[entity] 

      $.extend data, data[entity]
      delete data[entity]
      @_type = _.string.underscored className

  cast: -> App[_.string.classify(@_type)].find @id