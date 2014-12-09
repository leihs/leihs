###
  
  InventoryPool

###

class window.App.InventoryPool extends Spine.Model

  @configure "InventoryPool", "id", "name", "default_contract_note"

  @hasMany "availabilities", "App.Availability", "inventory_pool_id"
  @hasMany "models", "App.Model", "inventory_pool_id"
  @hasMany "holidays", "App.Holiday", "inventory_pool_id"
  @hasOne "workday", "App.Workday", "inventory_pool_id"

  @extend Spine.Model.Ajax

  @url: "/inventory_pools"

  isClosedOn: (date)=>
    _.include(@workday().closedDays(), date.day()) or
      _.any(@holidays().all(), (h)->
        (date.isAfter(h.start_date) and date.isBefore(h.end_date)) or
          date.isSame(h.start_date) or
          date.isSame(h.end_date)
      )

  isVisitPossible: (date)=>
    # NOTE check if the maximum visits limit has been reached
    @workday().reached_max_visits.indexOf(moment(date).format("YYYY-MM-DD")) is -1

  hasEnoughReservationAdvanceDays: (date)=>
    # NOTE check number of days between order submission and hand over
    date >= moment().startOf('day').add(@workday().reservation_advance_days, 'days')
