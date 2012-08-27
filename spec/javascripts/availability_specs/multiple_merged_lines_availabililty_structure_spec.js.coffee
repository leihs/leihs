describe "Merging multiple lines availability in total and for partitions", ->

  beforeEach ->
    @inventory_pool = {id: 1, closed_days: [0,6], name: "AV-Ausleihe"}
    @lines = []
    @lines[0] = 
      type: "item_line"
      quantity: 1
      model: {id: 5, type: "model"}
      availability_for_inventory_pool:
        inventory_pool: @inventory_pool   
        partitions: [{group_id: null, quantity: 2}]
        changes: 
          [["2012-02-27", 1, [{group_id: null, in_quantity: 1}]],
           ["2012-03-28", 2, [{group_id: null, in_quantity: 2}]],
           ["2012-06-01", 2, [{group_id: null, in_quantity: 2}]],
           ["2012-06-30", 2, [{group_id: null, in_quantity: 2}]]
          ]
    @lines[1] = 
      type: "item_line"
      quantity: 1
      model: {id: 6, type: "model"}
      availability_for_inventory_pool:
        inventory_pool: @inventory_pool   
        partitions: [{group_id: null, quantity: 1}]
        changes: 
          [["2012-02-27", 1, [{group_id: null, in_quantity: 1}]],
           ["2012-06-01", 1, [{group_id: null, in_quantity: 1}]],
           ["2012-06-30", 1, [{group_id: null, in_quantity: 1}]]
          ]
       
    @merged_lines_availabilities = new MultipleMergedLinesAvailabilities @lines
    
#-###################### merging total quantities

  it "is merging multiple lines total quantity so it has more then 0 elements", ->
    expect(@merged_lines_availabilities.changes.length > 0).toBeTruthy("Merge failed! No entry found")

  it "after merging lines total quantity the availability entries have to be unique", ->
    already_existing = {}
    for av_date in @merged_lines_availabilities.changes
      expect(already_existing[av_date[0]]).not.toBeDefined("Entry already existing"); 
      already_existing[av_date[0]] = av_date      
        
  it "still contains at least one entry for all dates that where already existing in the lines before they were merged", ->
    for line in @lines
      for line_av_date in line
        av_date_found = false
        for merged_av_date in @merged_lines_availabilities
          av_date_found = true if av_date[0] == merged_av_date[0]
        expect(av_date_found).toBeTruthy("Record not found") 
             
#-###################### merging nested partitions

  it "is merging multiple lines availability entrie's partitions as well", ->
    for av_date in @merged_lines_availabilities.changes
      expect(av_date[2].length == 1).toBeTruthy("Partition not merged correctly - two partitions found instead of one")
  
  it "is merging the partitions correct for a specific entry/date", ->
    for av_date in @merged_lines_availabilities.changes
      if av_date[0] == "2012-06-01"
        expect(av_date[1] == 1).toBeTruthy("Availability entry not merged correctly")
        expect(av_date[2][0].in_quantity == 1).toBeTruthy("Partition not merged correctly")