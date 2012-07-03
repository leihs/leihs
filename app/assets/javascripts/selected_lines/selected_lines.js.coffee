###

  Selected Lines
 
  This script sets up functionalities for selection based functionalities for multiple lines.
  
###

jQuery ->
  $(document).live "after_remove_line", ->
    SelectedLines.update_counter()

class SelectedLines
  
  @lines
  @lines_data
  
  @setup: ->
    @setup_single_line_selection()
    @setup_linegroup_selection()
    @toggle_on_selection()
    @update_counter()
  
  @setup_single_line_selection: ->
    $(".line .select input[type='checkbox']").live "change", (event)->
      console.log "CHANGE"
      SelectedLines.handle_linegroup_selection $(this).closest(".line")
      SelectedLines.store()
  
  @setup_linegroup_selection: ->
    $(".linegroup>.dates input[type='checkbox']").live "change", (event)->
      if $(this).is(":checked")
        $(this).closest(".linegroup").find(".line .select input").attr("checked", true).change()
      else
        $(this).closest(".linegroup").find(".line .select input").attr("checked", false).change()
        
  @handle_linegroup_selection: (line)->
    if $(line).find(".select input").is(":checked") and $(line).closest(".linegroup").find(".lines>.line .select input[type='checkbox']:not(:checked)").length == 0
      # select complete linegroup
      $(line).closest(".linegroup").find(".dates input[type='checkbox']").attr "checked", true
    else
      # unselect linegroup
      $(line).closest(".linegroup").find(".dates input[type='checkbox']").attr "checked", false
  
  @store: ->
    @lines = _.map $(".innercontent .line input:checked"), (input)-> $(input).closest(".line")
    @lines_data = _.map $(".innercontent .line input:checked"), (input)-> $(input).closest(".line").tmplItem().data
    @store_selected_line_ids()
    @toggle_on_selection()
    @update_counter()

  @store_selected_line_ids: ->
    $("[data-add_selected_line_ids]").each (i, element)->
      attr = if $(element).attr("href") then "href" else "action"
      value = $(element).attr(attr)
      value = value.replace(/\?.*$/, "")
      value = "#{value}?" if value.match(/\?$/) == null
      for line in SelectedLines.lines
        value = "#{value}&" if value.match(/[\?&]$/) == null
        value = "#{value}line_ids[]=#{$(line).tmplItem().data.id}"
      $(element).attr attr, value

  @toggle_on_selection: ->
    if @lines and @lines.length > 0
      $("[data-toggle_on_line_selection]").attr "disabled", false
      $("[data-toggle_on_line_selection]").find(".button").attr "disabled", false
    else
      $("[data-toggle_on_line_selection]").attr "disabled", true
      $("[data-toggle_on_line_selection]").find(".button").attr "disabled", true

  @restore: ->
    selected_line_ids = _.map SelectedLines.lines_data, (line)-> line.id
    selected_lines = _.filter $(".innercontent .line"), (line)-> _.include selected_line_ids, $(line).tmplItem().data.id
    $(selected_lines).find(".select input").attr("checked", true).change()
    @store()

  @update_counter: ->
    if @lines?
      text = "(#{@lines.length})"
      $("#selection_actions .selection .count").html(text)
  
window.SelectedLines = SelectedLines