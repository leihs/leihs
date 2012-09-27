###
  
  Line is a represantative of document lines (order / contract)

###

class Line

  # Merging lines is needed to merge multiple selected lines of the same model in the booking calendar to merge them to one line.
  # They have an additonal key/vaulue for storing the merged sub_line_ids.
  @mergeLines: (lines)->
    @mergedLines = []
    _.each lines, (line)=> 
      lineWithSameModel = _.find @mergedLines, (mergedLine)-> mergedLine.model.id == line.model.id
      if line.model.type == "model" and lineWithSameModel?
        lineWithSameModel.quantity += line.quantity
        lineWithSameModel.sublines = [lineWithSameModel] if not lineWithSameModel.sublines?
        lineWithSameModel.sublines.push line
        # merge the availability of the merged line while detaching the new subline
        lineWithSameModel.availability_for_inventory_pool.changes = new App.AvailabilityChanges(lineWithSameModel.availability_for_inventory_pool.changes).withoutLines([line]) 
      else
        newLine = JSON.parse(JSON.stringify(line))
        newLine.availability_for_inventory_pool.changes = new App.AvailabilityChanges(newLine.availability_for_inventory_pool.changes).withoutLines([newLine]) 
        @mergedLines.push newLine
    return @mergedLines

window.App.Line = Line