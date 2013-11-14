class window.App.TakeBackDialogController extends Spine.Controller

  constructor: ->
    super
    do @setupModal
    @el.on "click", "[data-take-back]", @takeBack

  setupModal: =>
    lines = _.map @lines, (line)-> 
      line.end_date = moment().format("YYYY-MM-DD")
      line
    data = 
      groupedLines: App.Modules.HasLines.groupByDateRange lines, true
      user: @user
      itemsCount: @getItemsCount()
    options = 
      returnedQuantity: @returnedQuantity
    @modal = new App.Modal App.Render "manage/views/users/take_back_dialog", data, options
    @el = @modal.el

  getItemsCount: => _.reduce @lines, ((mem,l)=> (@returnedQuantity[l.id]||l.quantity) + mem), 0

  takeBack: =>
    @modal.undestroyable()
    @modal.el.detach()
    App.ContractLine.takeBack(@lines, @returnedQuantity)
    .done (data)=> @showDocuments @lines

  showDocuments: (lines)=>
    contracts = _.uniq(_.map(lines, (l)->l.contract()), (c) -> c.id)
    tmpl = App.Render "manage/views/users/take_back_documents_dialog", {user: @user, contracts: contracts, itemsCount: @getItemsCount()}
    modal = new App.Modal tmpl
    modal.undestroyable()