###

  Inventory

###

class window.App.Inventory extends Spine.Model

  @types: ["option", "model", "software", "item"]

  @findOrCreate: (datum) =>
    if type = @getType(datum)
      className = _.string.classify(type)
      inventoryModel = App[className]
      data = datum[type]
      inventoryModel.exists(data["id"]) ? inventoryModel.addRecord(new inventoryModel data)
    else
      throw new Error "unrecognized inventory type"

  @getType: (datum) => _.find @types, (type) -> datum[type]?
