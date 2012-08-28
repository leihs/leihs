describe "Merging multiple lines", ->

  beforeEach ->
    @line1 = 
      availability_for_inventory_pool:
        changes: [
                 ["2012-01-01", 0, [{group_id: null, in_quantity: 0, out_document_lines: {ItemLine: [101, 102, 103, 104]}}]],
                 ["2012-01-03", 0, [{group_id: null, in_quantity: 0, out_document_lines: {ItemLine: [103, 104], OrderLine: [23]}}]],
                 ["2012-01-08", 2, [{group_id: null, in_quantity: 2, out_document_lines: {ItemLine: [105, 106]}}]],
                 ["2012-01-12", 3, [{group_id: null, in_quantity: 3, out_document_lines: {ItemLine: [107]}}]],
                 ["2012-01-15", 4, [{group_id: null, in_quantity: 4}]],
                ]
      contract: {id: 99} 
      id: 4
      model: {id: 4, type: "model"}
      quantity: 1
      start_date: "2012-01-03"
      end_date: "2012-01-08"
      type: "item_line"

    @line2 = 
      availability_for_inventory_pool:
        changes: [
                 ["2012-01-01", 0, [{group_id: null, in_quantity: 0, out_document_lines: {ItemLine: [101, 102, 103, 104]}}]],
                 ["2012-01-03", 0, [{group_id: null, in_quantity: 0, out_document_lines: {ItemLine: [4, 104], OrderLine: [23]}}]],
                 ["2012-01-08", 2, [{group_id: null, in_quantity: 2, out_document_lines: {ItemLine: [105, 106]}}]],
                 ["2012-01-12", 3, [{group_id: null, in_quantity: 3, out_document_lines: {ItemLine: [107]}}]],
                 ["2012-01-15", 4, [{group_id: null, in_quantity: 4}]],
                ]
      contract: {id: 99} 
      id: 103
      model: {id: 4, type: "model"}
      quantity: 1
      start_date: "2012-01-03"
      end_date: "2012-01-08"
      type: "item_line"

    @line3 = 
      availability_for_inventory_pool:
        changes: [
                 ["2012-01-01", 0, [{group_id: null, in_quantity: 0, out_document_lines: {ItemLine: [34, 35, 36, 37]}}]],
                 ["2012-01-06", 1, [{group_id: null, in_quantity: 1, out_document_lines: {ItemLine: [100], OrderLine: [40, 41, 42]}}]],
                 ["2012-01-12", 3, [{group_id: null, in_quantity: 3, out_document_lines: {ItemLine: [46]}}]],
                 ["2012-01-15", 4, [{group_id: null, in_quantity: 4}]],
                 ]
      contract: {id: 102} 
      id: 99
      model: {id: 8, type: "model"}
      quantity: 2
      start_date: "2012-01-06"
      end_date: "2012-01-12"
      type: "item_line"

    @line4 = 
      availability_for_inventory_pool:
        changes: [
                 ["2012-01-01", 0, [{group_id: null, in_quantity: 0, out_document_lines: {ItemLine: [34, 35, 36, 37]}}]],
                 ["2012-01-06", 0, [{group_id: null, in_quantity: 0, out_document_lines: {ItemLine: [99], OrderLine: [40, 41, 42]}}]],
                 ["2012-01-12", 3, [{group_id: null, in_quantity: 3, out_document_lines: {ItemLine: [46]}}]],
                 ["2012-01-15", 4, [{group_id: null, in_quantity: 4}]],
                 ]
      contract: {id: 99}
      id: 100
      model: {id: 8, type: "model"}
      quantity: 1
      start_date: "2012-01-06"
      end_date: "2012-01-12"
      type: "item_line"

    @mergedLines1 = App.Line.mergeLines [@line1, @line2]
    @mergedLines2 = App.Line.mergeLines [@line1, @line2, @line3, @line4]
    
#######################

  it "is merging multiple lines of the same model", ->
    expect(@mergedLines1.length == 1).toBeTruthy("merge failed for line 1 and 2")
    expect(@mergedLines2.length == 2).toBeTruthy("merge failed for line 1, 2, 3 and 4")
    
  it "is storing all envolved lines in the new lines attribute called sublines", ->
    expect(@mergedLines1[0].sublines[0].id == 4).toBeTruthy("sublines not allocated correctly for model id 4")
    expect(@mergedLines1[0].sublines[1].id == 103).toBeTruthy("sublines not allocated correctly for model id 4")
    expect(@mergedLines2[0].sublines[0].id == 4).toBeTruthy("sublines not allocated correctly for model id 4")
    expect(@mergedLines2[0].sublines[1].id == 103).toBeTruthy("sublines not allocated correctly for model id 4")
    expect(@mergedLines2[1].sublines[0].id == 99).toBeTruthy("sublines not allocated correctly for model id 8")
    expect(@mergedLines2[1].sublines[1].id == 100).toBeTruthy("sublines not allocated correctly for model id 8")

  it "is summing up the merged lines quantity", ->
    expect(@mergedLines1[0].quantity == 2).toBeTruthy("mergedLines1 quantity for line 1 and 2 is not correctly summed up")
    expect(@mergedLines2[0].quantity == 2).toBeTruthy("mergedLines2 quantity for line 1 and 2 is not correctly summed up")
    expect(@mergedLines2[1].quantity == 3).toBeTruthy("mergedLines2 quantity for line 3 and 4 is not correctly summed up")

  it "is removing all sublines from the merged lines availability", ->
    expectation_for_mergedLines1 = not _.any @mergedLines1[0].availability_for_inventory_pool.changes, (change)->
      _.any change[2], (allocation)-> 
        if allocation.out_document_lines? and allocation.out_document_lines.ItemLine?
          _.include(allocation.out_document_lines.ItemLine, 4) or _.include(allocation.out_document_lines.ItemLine, 103)
        else
          false
    expect(expectation_for_mergedLines1).toBeTruthy("The availability changes of mergedLines1 for line 1 and 2 is not correctly freed/unblocked")
    expectation_for_mergedLines2_0 = not _.any @mergedLines2[0].availability_for_inventory_pool.changes, (change)->
      _.any change[2], (allocation)-> 
        if allocation.out_document_lines? and allocation.out_document_lines.ItemLine?
          _.include(allocation.out_document_lines.ItemLine, 4) or _.include(allocation.out_document_lines.ItemLine, 103)
        else
          false
    expectation_for_mergedLines2_1 = not _.any @mergedLines2[1].availability_for_inventory_pool.changes, (change)->
      _.any change[2], (allocation)-> 
        if allocation.out_document_lines? and allocation.out_document_lines.ItemLine?
          _.include(allocation.out_document_lines.ItemLine, 99) or _.include(allocation.out_document_lines.ItemLine, 100)
        else
          false
    expect(expectation_for_mergedLines2_0 and expectation_for_mergedLines2_1).toBeTruthy("The availability changes of mergedLines2 for line 1,2,3 and 4 is not correctly freed/unblocked")
