describe "Merging multiple lines availability in total and for partitions", ->
  
  beforeEach ->
    @inventory_pool = {id: 1, closed_days: [0,6], name: "AV-Ausleihe"}
    @lines = []
    @lines[0] = availability_for_inventory_pool:
      inventory_pool: @inventory_pool   
      partitions: [{group_id: null, quantity: 4}, {group_id: 1, quantity: 2}]
      availability: 
        [["2012-01-01", 0, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: 0}]],
         ["2012-01-02", 0, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: 0}]],
         ["2012-01-03", 0, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: 0}]],
         ["2012-01-12", 2, [{group_id: null, in_quantity: 2}, {group_id: 1, in_quantity: 0}]]
        ]
    @lines[1] = availability_for_inventory_pool:
      inventory_pool: @inventory_pool   
      partitions: [{group_id: null, quantity: 4}, {group_id: 1, quantity: 2}]
      availability: 
        [["2012-01-01", 0, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: 0}]],
         ["2012-01-02", 2, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: 0}]],
         ["2012-01-04", 1, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: 0}]],
         ["2012-01-12", 2, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: 0}]] 
        ]
    @lines[2] = availability_for_inventory_pool:
      inventory_pool: @inventory_pool   
      partitions: [{group_id: null, quantity: 4}, {group_id: 1, quantity: 2}]
      availability: 
        [["2012-01-01", 0, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: 0}]],
         ["2012-01-02", 3, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: 0}]],
         ["2012-01-12", 2, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: 0}]]
        ]
    @lines[3] = availability_for_inventory_pool:
      inventory_pool: @inventory_pool   
      partitions: [{group_id: null, quantity: 4}, {group_id: 1, quantity: 2}]
      availability:
        [["2012-01-01", 0, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: 0}]],
         ["2012-01-02", 1, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: 0}]],
         ["2012-01-12", 2, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: 0}]]
        ]
    @lines[4] = availability_for_inventory_pool:
      inventory_pool: @inventory_pool   
      partitions: [{group_id: null, quantity: 4}, {group_id: 1, quantity: 2}]
      availability: 
        [["2012-01-01", 0, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: 0}]],
         ["2012-01-02", 4, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: 0}]],
         ["2012-01-12", 2, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: 0}]]
        ]
    @lines[5] = availability_for_inventory_pool:
      inventory_pool: @inventory_pool   
      partitions: [{group_id: null, quantity: 4}, {group_id: 1, quantity: 2}]
      availability: 
        [["2012-01-01", 0, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: 0}]],
         ["2012-01-02", 2, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: 0}]],
         ["2012-01-12", 2, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: 0}]]
        ]
       
    @merged_lines_availabilities = new MultipleMergedLinesAvailabilities @lines
    
#-######################

  it "is merging multiple lines total quantity so it has more then 0 elements", ->
    expect(@merged_lines_availabilities.availability.length > 0).toBeTruthy("Merge failed! No entry found")

  it "after merging lines total quantity the availability entries have to be unique", ->
    already_existing = {}
    for av_date in @merged_lines_availabilities.availability
      expect(already_existing[av_date[0]]).not.toBeDefined("Entry already existing"); 
      already_existing[av_date[0]] = av_date      
        
  it "still contains at least one entry for all dates that where already existing in the lines before they were merged", ->
    for line in @lines
      for line_av_date in line
        av_date_found = false
        for merged_av_date in @merged_lines_availabilities
          av_date_found = true if av_date[0] == merged_av_date[0]
        expect(av_date_found).toBeTruthy("Record not found") 
             
  it "is merging one specific availability entry (in this case: 2012-01-01) to 0 (unavailable) if all lines have this entry as well setted as 0 (unavailable)", ->
    for av_date in @merged_lines_availabilities.availability
      expect(av_date[1] == 0).toBeTruthy("Summed total quantity for the 2012-01-01 is not correct") if av_date[0] == "2012-01-01"

  it "is merging one specific availability entry (in this case: 2012-01-02) to 0 (unavailable) if all lines have this entry setted greater then 0 but one has 0 (unavailable)", ->
    for av_date in @merged_lines_availabilities.availability
      expect(av_date[1] == 0).toBeTruthy("Summed total quantity for the 2012-01-02 is not correct") if av_date[0] == "2012-01-02"
        
  it "is merging one specific availability entry (in this case: 2012-01-12) to 1 (available) if all lines have this entry setted greater then 0 (available)", ->
    for av_date in @merged_lines_availabilities.availability
      expect(av_date[1] == 1).toBeTruthy("Summed total quantity for the 2012-01-12 is not correct") if av_date[0] == "2012-01-12"
        
  it "is merging one specific availability entry (in this case: 2012-01-04) to 0 (unavailable) if only one line has a entry for this date explicitly setted to greater then 0 (available) but one other's line latest entry is 0 (unavailable)", ->
    for av_date in @merged_lines_availabilities.availability
      expect(av_date[1] == 0).toBeTruthy("Summed total quantity for the 2012-01-04 is not correct") if av_date[0] == "2012-01-04"
      
#-######################

   it "is making a union of the possible partitions", ->
    expect(@merged_lines_availabilities.partitions.length == 2).toBeTruthy("Partitions not unified")
