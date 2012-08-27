describe "Availability Changes", ->

  beforeEach ->
    @changes = 
      [["2012-01-01", -1, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: -1}, {group_id: 2, in_quantity: 0}]],
       ["2012-01-02", -5, [{group_id: null, in_quantity: 0}, {group_id: 1, in_quantity: -1}, {group_id: 2, in_quantity: -4}]],
       ["2012-01-03", 1, [{group_id: null, in_quantity: 2}, {group_id: 1, in_quantity: 0}, {group_id: 2, in_quantity: -1}]],
       ["2012-01-12", 2, [{group_id: null, in_quantity: 1}, {group_id: 1, in_quantity: 0}, {group_id: 2, in_quantity: 1}]],
       ["2012-01-15", 4, [{group_id: null, in_quantity: 4}, {group_id: 1, in_quantity: 1}, {group_id: 2, in_quantity: -1}]]
      ]
    @availability = new App.Availability {changes: @changes}
    
#######################

  it "stores the end date of each change on construction", ->
    _.each @availability.changes.changes, (change)->
      expect(change[3]).toBeDefined()
    expect(@availability.changes.changes[2][3] == "2012-01-11").toBeTruthy("endDate was not computed and stored correctly")
    