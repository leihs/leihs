App.Modules.NestedData = 

  nested: (data, attr, Model, idAttr = "id")->
    return true unless data[attr]?
    for datum in (if (data[attr] instanceof Array) then data[attr] else Array(data[attr]))
      Model.addRecord new Model datum unless Model.findByAttribute(idAttr, datum[idAttr])?
    data[attr] = null