describe "Availability without specific document lines", ->

  beforeEach ->
    @changes = 
      [
       ["2012-01-01", 0, [{group_id: null, in_quantity: 0, out_document_lines: {ItemLine: [101, 102, 103, 104]}}]],
       ["2012-01-03", 0, [{group_id: null, in_quantity: 0, out_document_lines: {ItemLine: [103, 104, 105], OrderLine: [23]}}]],
       ["2012-01-08", 2, [{group_id: null, in_quantity: 2, out_document_lines: {ItemLine: [105, 106]}}]],
       ["2012-01-12", 3, [{group_id: null, in_quantity: 3, out_document_lines: {ItemLine: [107]}}]],
       ["2012-01-15", 4, [{group_id: null, in_quantity: 4}]],
      ]
    @availability = new App.Availability {changes: @changes}
    
#######################

  it "provides the availability changes without one or multiple specific document line ids", ->
    order_line_23 = {id: 23, type: "order_line", quantity: 1}
    without_23 = _.any @availability.changes.withoutSpecificDocumentLines([order_line_23]), (change)-> 
      _.any change[2], (allocation)->
        if allocation.out_document_lines? and allocation.out_document_lines.OrderLine?
          _.include allocation.out_document_lines.OrderLine, 23
    expect(without_23).toBeFalsy("Removing Order Line 23 from the changes fails")
    freed_change = _.find @availability.changes.withoutSpecificDocumentLines([order_line_23]), (c)-> c[0]=="2012-01-03"
    expect(freed_change[1] == 1).toBeTruthy("Freeing the total quantity was failing for order line 23")
    freed_allocation = _.find freed_change[2], (allocation)-> allocation.group_id == null
    expect(freed_allocation.in_quantity == 1).toBeTruthy("Freeing the in_quantity of group_id=null was failing for order line 23")
