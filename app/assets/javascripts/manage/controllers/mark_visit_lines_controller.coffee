###

  Marked Lines
 
  This script sets up functionalities for marking selected visit lines
  
###

class window.App.MarkVisitLinesController extends Spine.Controller

  update: (ids) =>
    do @unmarkAllLines
    @markSelectedLines ids

  unmarkAllLines: =>
    for line in @el.find(".line[data-id]")
      $(line).removeClass("green").addClass("light")

  markSelectedLines: (ids) =>
    for id in ids
      cl = App.ContractLine.find(id)
      if cl.item()
        line = @el.find(".line[data-id='#{id}']")
        line.removeClass("light").addClass("green")
      else if cl.option()
        line = @el.find(".line[data-id='#{id}']")
        c_status = cl.contract().status
        if c_status == "approved"
          line.removeClass("light").addClass("green") if Number(line.find("input[data-line-quantity]").val()) >= 1
        else if c_status == "signed"
          line.removeClass("light").addClass("green") if Number(line.find("input[data-quantity-returned]").val()) == cl.quantity
