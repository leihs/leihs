class window.App.TakeBackDialogController extends Spine.Controller

  constructor: ->
    super
    do @setupModal
    @el.on "click", "[data-take-back]", @takeBack

  setupModal: =>
    reservations = _.map @reservations, (line)->
      line.end_date = moment().format("YYYY-MM-DD")
      line
    data = 
      groupedLines: App.Modules.HasLines.groupByDateRange reservations, true
      user: @user
      itemsCount: @getItemsCount()
    options = 
      returnedQuantity: @returnedQuantity
    @modal = new App.Modal App.Render "manage/views/users/take_back_dialog", data, options
    @el = @modal.el

  getItemsCount: => _.reduce @reservations, ((mem,l)=> (@returnedQuantity[l.id]||l.quantity) + mem), 0

  takeBack: =>
    @modal.undestroyable()
    @modal.el.detach()
    App.Reservation.takeBack(@reservations, @returnedQuantity)
    .done (data)=> @showDocuments @reservations

  showDocuments: (reservations)=>
    contracts = _.uniq(_.map(reservations, (l)->l.contract()), (c) -> c.id)
    tmpl = App.Render "manage/views/users/take_back_documents_dialog", {user: @user, contracts: contracts, itemsCount: @getItemsCount()}
    modal = new App.Modal tmpl
    modal.undestroyable()