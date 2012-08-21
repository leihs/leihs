describe "Availability", ->

  beforeEach ->
    @changes = 
      [["2012-01-01", -1, [{group_id: 0, in_quantity: 0}, {group_id: 1, in_quantity: -1}, {group_id: 2, in_quantity: 0}]],
       ["2012-01-02", -5, [{group_id: 0, in_quantity: 0}, {group_id: 1, in_quantity: -1}, {group_id: 2, in_quantity: -4}]],
       ["2012-01-03", 1, [{group_id: 0, in_quantity: 2}, {group_id: 1, in_quantity: 0}, {group_id: 2, in_quantity: -1}]],
       ["2012-01-12", 2, [{group_id: 0, in_quantity: 1}, {group_id: 1, in_quantity: 0}, {group_id: 2, in_quantity: 1}]],
       ["2012-01-15", 4, [{group_id: 0, in_quantity: 4}, {group_id: 1, in_quantity: 1}, {group_id: 2, in_quantity: -1}]]
      ]
    @availability = new App.Availability @changes
    
#######################

  it "returns the most recent change", ->
    expect(@availability.mostRecentOrEqualDate(new Date(2011,0,1)).toJSON() == new Date(2011,0,1).toJSON())
      .toBeTruthy("most recent change for 2011-01-01 is incorrect")
    expect(@availability.mostRecentOrEqualDate(new Date(2012,0,2)).toJSON() == new Date(2012,0,2).toJSON())
      .toBeTruthy("most recent change for 2012-01-02 is incorrect")
    expect(@availability.mostRecentOrEqualDate(new Date(2012,0,5)).toJSON() == new Date(2012,0,3).toJSON())
      .toBeTruthy("most recent change for 2012-01-05 is incorrect")
    expect(@availability.mostRecentOrEqualDate(new Date(2012,0,13)).toJSON() == new Date(2012,0,12).toJSON())
      .toBeTruthy("most recent change for 2012-01-13 is incorrect")
    expect(@availability.mostRecentOrEqualDate(new Date(2012,0,16)).toJSON() == new Date(2012,0,15).toJSON())
      .toBeTruthy("most recent change for 2012-01-16 is incorrect")

  it "returns the changes between a range", ->
    expect(_.difference(_.map(@availability.changesBetween(new Date(2011,0,1), new Date(2012,0,1)), ((change)->change[0])), ["2012-01-01"]).length == 0 )
      .toBeTruthy("changes between 2011-01-01 and 2012-01-01 incorrect")
    expect(_.difference(_.map(@availability.changesBetween(new Date(2011,0,1), new Date(2012,0,4)), ((change)->change[0])), ["2012-01-01", "2012-01-02", "2012-01-03"]).length == 0 )
      .toBeTruthy("changes between 2011-01-01 and 2012-01-04 incorrect")
    expect(_.difference(_.map(@availability.changesBetween(new Date(2011,0,1), new Date(2012,0,13)), ((change)->change[0])), ["2012-01-01", "2012-01-02", "2012-01-03", "2012-01-12"]).length == 0 )
      .toBeTruthy("changes between 2011-01-01 and 2012-01-13 incorrect")
    expect(_.difference(_.map(@availability.changesBetween(new Date(2011,0,1), new Date(2012,0,16)), ((change)->change[0])), ["2012-01-01", "2012-01-02", "2012-01-03", "2012-01-12", "2012-01-15"]).length == 0 )
      .toBeTruthy("changes between 2011-01-01 and 2012-01-16 incorrect")
    expect(_.difference(_.map(@availability.changesBetween(new Date(2012,0,14), new Date(2012,0,16)), ((change)->change[0])), ["2012-01-12", "2012-01-15"]).length == 0 )
      .toBeTruthy("changes between 2012-01-14 and 2012-01-16 incorrect")
    expect(_.difference(_.map(@availability.changesBetween(new Date(2012,0,16), new Date(2012,0,16)), ((change)->change[0])), ["2012-01-15"]).length == 0 )
      .toBeTruthy("changes between 2012-01-16 and 2012-01-16 incorrect")

  it "gets maximum available in total for a specific time range without considering in which groups the user is", ->
    expect(@availability.maxAvailableInTotal(new Date(2012,0,1), new Date(2012,0,15)) == -5)
      .toBeTruthy("max available between 2012-01-01 and 2012-01-15 is incorrect")
    expect(@availability.maxAvailableInTotal(new Date(2012,0,1), new Date(2012,0,2)) == -5)
      .toBeTruthy("max available between 2012-01-01 and 2012-01-02 is incorrect")
    expect(@availability.maxAvailableInTotal(new Date(2012,0,2), new Date(2012,0,2)) == -5)
      .toBeTruthy("max available between 2012-01-02 and 2012-01-02 is incorrect")

  it "gets maximum available for a specific time range for the provided group ids", ->
    expect(@availability.maxAvailableForGroups(new Date(2012,0,1), new Date(2012,0,15), [2]) == -4)
      .toBeTruthy("max available for groups [2] between 2012-01-01 and 2012-01-15 is incorrect")
    expect(@availability.maxAvailableForGroups(new Date(2012,0,12), new Date(2012,0,15), [1]) == 1)
      .toBeTruthy("max available for groups [1] between 2012-01-12 and 2012-01-15 is incorrect")
    expect(@availability.maxAvailableForGroups(new Date(2012,0,12), new Date(2012,0,15), [1,2]) == 2)
      .toBeTruthy("max available for groups [1,2] between 2012-01-12 and 2012-01-15 is incorrect")
    expect(@availability.maxAvailableForGroups(new Date(2012,0,15), new Date(2012,0,16), [1,2]) == 4)
      .toBeTruthy("max available for groups [1,2] between 2012-01-15 and 2012-01-16 is incorrect")
    expect(@availability.maxAvailableForGroups(new Date(2012,0,3), new Date(2012,0,5), [1,2]) == 1)
      .toBeTruthy("max available for groups [1,2] between 2012-01-03 and 2012-01-05 is incorrect")

  it "gets the available unavailable status for a date range and provided groupIds", ->
    expect(@availability.isAvailable(new Date(2012,0,1), new Date(2012,0,15), 1) == false)
      .toBeTruthy("availability is incorrect for 2012-1-1 until 2012-1-15 for quantity 1")
    expect(@availability.isAvailable(new Date(2012,0,12), new Date(2012,0,15), 2) == true)
      .toBeTruthy("availability is incorrect for 2012-1-12 until 2012-1-15 for quantity 2")
    expect(@availability.isAvailable(new Date(2012,0,12), new Date(2012,0,15), 2, [2]) == true)
      .toBeTruthy("availability is incorrect for 2012-1-12 until 2012-1-15 for quantity 2 and groupIds [2]")
    expect(@availability.isAvailable(new Date(2012,0,12), new Date(2012,0,15), 1, [1]) == true)
      .toBeTruthy("availability is incorrect for 2012-1-12 until 2012-1-15 for quantity 1 and groupIds [1]")
    expect(@availability.isAvailable(new Date(2012,0,12), new Date(2012,0,15), 2, [1]) == false)
      .toBeTruthy("availability is incorrect for 2012-1-12 until 2012-1-15 for quantity 2 and groupIds [1]")