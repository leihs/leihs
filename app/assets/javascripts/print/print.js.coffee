###

Print

This script provides functionalities for printing
 
###

jQuery ->
  
  $("#print .print").live "click", (e)-> do Print.print

class Print

  @print: ->
    title_before = document.title 
    document.title = $(".ui-dialog").find(".documents>.active").data("print_title") 
    $("html").addClass "print"
    do window.print
    # lets wait for opera to have the correct title inside of the contract
    window.setTimeout -> 
      document.title = title_before
      $("html").removeClass "print"
    , 200
  
  @map_contract_ids: (contracts)-> _.map contracts, (contract)-> contract.id
  
window.Print = Print