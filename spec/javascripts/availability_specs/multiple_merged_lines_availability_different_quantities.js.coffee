describe "Merging multiple lines availability for different quantites", ->

  beforeEach ->
    @lines = []
    @lines[0] = 
      quantity: 1
      type: "item_line"
      model: {id: 2, type: "model"}
      availability_for_inventory_pool:
        inventory_pool: @inventory_pool   
        partitions: [{group_id: null, quantity: 4}, {group_id: 1, quantity: 2}, {group_id: 2, quantity: 2}]
        changes: 
          [["2012-01-01", 0, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: 0}, {group_id: 2, in_quantity: 0}]],
           ["2012-01-02", 0, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: 0}, {group_id: 2, in_quantity: 0}]],
           ["2012-01-03", 0, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: 0}, {group_id: 2, in_quantity: 0}]],
           ["2012-01-12", 2, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: 2}, {group_id: 2, in_quantity: 0}]],
           ["2012-01-15", 4, [{group_id: null, in_quantity: 2}, {group_id: 1, in_quantity: 0}, {group_id: 2, in_quantity: 2}]]
          ]
    @lines[1] = 
      quantity: 2
      type: "item_line"
      model: {id: 3, type: "model"}
      availability_for_inventory_pool:
        inventory_pool: @inventory_pool   
        partitions: [{group_id: null, quantity: 4}, {group_id: 1, quantity: 2}, {group_id: 2, quantity: 2}]
        changes: 
          [["2012-01-01", 0, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: 0}, {group_id: 2, in_quantity: 0}]],
           ["2012-01-02", 2, [{group_id: null, in_quantity: 2}, {group_id: 1, in_quantity: 0}, {group_id: 2, in_quantity: 0}]],
           ["2012-01-04", 1, [{group_id: null, in_quantity: 1}, {group_id: 1, in_quantity: 0}, {group_id: 2, in_quantity: 0}]],
           ["2012-01-12", 2, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: 2}, {group_id: 2, in_quantity: 0}]],
           ["2012-01-15", 4, [{group_id: null, in_quanti ty: 2}, {group_id: 1, in_quantity: 0}, {group_id: 2, in_quantity: 2}]]
          ]
    @lines[2] = 
      quantity: 1
      type: "item_line"
      model: {id: 4, type: "model"}
      availability_for_inventory_pool:
        inventory_pool: @inventory_pool   
        partitions: [{group_id: null, quantity: 4}, {group_id: 1, quantity: 2}, {group_id: 2, quantity: 2}]
        changes: 
          [["2012-01-01", 0, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: 0}, {group_id: 2, in_quantity: 0}]],
           ["2012-01-02", 3, [{group_id: null, in_quantity: 3}, {group_id: 1, in_quantity: 0}, {group_id: 2, in_quantity: 0}]],
           ["2012-01-12", 2, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: 2}, {group_id: 2, in_quantity: 0}]],
           ["2012-01-15", 2, [{group_id: null, in_quantity: 2}, {group_id: 1, in_quantity: 0}, {group_id: 2, in_quantity: 2}]]
          ]
    @lines[3] = 
      type: "item_line"
      quantity: 1
      model: {id: 4, type: "model"}
      availability_for_inventory_pool:
        inventory_pool: @inventory_pool   
        partitions: [{group_id: null, quantity: 4}, {group_id: 1, quantity: 2}, {group_id: 2, quantity: 2}]
        changes:
          [["2012-01-01", 0, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: 0}, {group_id: 2, in_quantity: 0}]],
           ["2012-01-02", 1, [{group_id: null, in_quantity: 1}, {group_id: 1, in_quantity: 0}, {group_id: 2, in_quantity: 0}]],
           ["2012-01-12", 2, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: 2}, {group_id: 2, in_quantity: 0}]],
           ["2012-01-15", 4, [{group_id: null, in_quantity: 2}, {group_id: 1, in_quantity: 0}, {group_id: 2, in_quantity: 2}]]
          ]
       
    @merged_lines_availabilities = new MultipleMergedLinesAvailabilities @lines
    
#-###################### merging total quantities

  it "is merging multiple lines", ->
    # upcoming
    # expect(@merged_lines_availabilities.changes.length == 6).toBeTruthy("Merge failed!")
    # expect(_.find(@merged_lines_availabilities.changes, ((change)->change[0] == "2012-01-12"))[1] == 0).toBeTruthy("The lines[3] needs quantity 2, so for the '2012-01-12' it should be unavailable")
    # expect(_.find(@merged_lines_availabilities.changes, ((change)->change[0] == "2012-01-12"))[2][1].in_quantity == 0).toBeTruthy("The lines[3] needs quantity 2, so for the '2012-01-12' it should be unavailable")
  
    
