# encoding: utf-8

Angenommen /^ich editiere eine Bestellung( die nicht in der Vergangenheit liegt)?$/ do |arg1|
  @event = "order"
  step "I open a contract for acknowledgement%s" % (arg1 ? ", whose start date is not in the past" : "")
end

Angenommen /^ich mache eine Rücknahme(, die nicht überfällig ist)?$/ do |arg1|
  @event = "take_back"
  if arg1
    step 'I open a take back, not overdue'
  else
    step 'I open a take back'
  end
end

Angenommen /^ich mache eine Aushändigung$/ do
  @event = "hand_over"
  step 'I open a hand over'
end

Angenommen /^ein Modell ist nichtmehr verfügbar$/ do
  if @event=="order" or @event=="hand_over"
    @entity = if @contract
                @contract
              else
                @customer.get_approved_contract(@current_inventory_pool)
              end
    contract_line = @entity.lines.sample
    @model = contract_line.model
    @initial_quantity = @contract.lines.where(model_id: @model.id).count
    @max_before = contract_line.model.availability_in(@entity.inventory_pool).maximum_available_in_period_summed_for_groups(contract_line.start_date, contract_line.end_date, contract_line.group_ids)
    step 'I add so many lines that I break the maximal quantity of an model'
  else
    contract_line = @contract_lines_to_take_back.where(option_id: nil).sample
    @model = contract_line.model
    visit manage_hand_over_path(@current_inventory_pool, @customer)
    @max_before = @model.availability_in(@current_inventory_pool).maximum_available_in_period_summed_for_groups(contract_line.start_date, contract_line.end_date, contract_line.group_ids)
    step 'I add so many lines that I break the maximal quantity of an model'
    visit manage_take_back_path(@current_inventory_pool, @customer)
  end
  sleep(0.33)
  find(".line", text: @model.name, match: :first)
  @lines = all(".line", text: @model.name)
  expect(@lines.size).to be > 0
  @max_before = [@max_before, 0].max
end

Dann /^sehe ich auf den beteiligten Linien die Auszeichnung von Problemen$/ do
  @problems = []
  @lines.each do |line|
    sleep(0.33)
    hover_for_tooltip line.find("[data-tooltip-template='manage/views/lines/problems_tooltip']")
    @problems << find(".tooltipster-content strong", match: :first).text
  end
  @reference_line = @lines.first
  @reference_problem = @problems.first
  @line = if @reference_line["data-id"]
            ContractLine.find @reference_line["data-id"]
          else
            ContractLine.find JSON.parse(@reference_line["data-ids"]).first
          end
  @av = @line.model.availability_in(@line.inventory_pool)
end

Dann /^das Problem wird wie folgt dargestellt: "(.*?)"$/ do |format|
  regexp = if format == "Nicht verfügbar 2(3)/7"
             /#{_("Not available")} -*\d\(-*\d\)\/\d/
           elsif format == "Gegenstand nicht ausleihbar"
             /#{_("Item not borrowable")}/
           elsif format == "Gegenstand ist defekt"
             /#{_("Item is defective")}/
           elsif format == "Gegenstand ist unvollständig"
             /#{_("Item is incomplete")}/
           elsif format == "Überfällig seit 6 Tagen"
             /(Überfällig seit \d+ (Tagen|Tag)|#{_("Overdue")} #{_("since")} \d+ (days|day))/
           end
  @problems.each do |problem|
    expect(problem.match(regexp)).not_to be nil
  end
end

Dann /^"(.*?)" sind verfügbar für den Kunden inklusive seinen Gruppenzugehörigen$/ do |arg1|
  max = if [:unsubmitted, :submitted].include? @line.contract.status
          @initial_quantity + @max_before
        elsif [:approved, :signed].include? @line.contract.status
          @av.maximum_available_in_period_summed_for_groups(@line.start_date, @line.end_date, @line.group_ids) + 1 # free up self blocking
        else
          @max_before - @quantity_added
        end
  expect(@reference_problem).to match /#{max}\(/
end

Dann /^"(.*?)" sind insgesamt verfügbar inklusive diejenigen Gruppen, welchen der Kunde nicht angehört$/ do |arg1|
  max = @av.maximum_available_in_period_summed_for_groups(@line.start_date, @line.end_date, @av.inventory_pool_and_model_group_ids)
  if [:unsubmitted, :submitted].include? @line.contract.status
    max += @line.contract.lines.where(:start_date => @line.start_date, :end_date => @line.end_date, :model_id => @line.model).size
  else
    max += @line.quantity
  end
  expect(@reference_problem).to match(/\(#{max}/)
end

Dann /^"(.*?)" sind total im Pool bekannt \(ausleihbar\)$/ do |arg1|
  expect(@reference_problem).to match("/#{@line.model.items.where(inventory_pool_id: @line.inventory_pool).borrowable.size}")
end

Angenommen /^eine Gegenstand ist nicht ausleihbar$/ do
  if @event == "hand_over"
    @item = @current_inventory_pool.items.in_stock.unborrowable.sample
    step 'I add an item to the hand over'
    sleep(0.33)
    @line_id = ContractLine.where(item_id: @item.id).first.id
    find(".line[data-id='#{@line_id}']", text: @item.model.name).find("[data-assign-item][disabled]")
  elsif @event === "take_back"
    @line_id = find(".line[data-line-type='item_line']", match: :first)[:"data-id"]
    step 'markiere ich den Gegenstand als nicht ausleihbar'
  end
end

Angenommen /^ich mache eine Rücknahme eines( verspäteten)? Gegenstandes$/ do |arg1|
  @event = "take_back"
  overdued_take_backs = @current_inventory_pool.visits.take_back.select{|v| v.lines.any? {|l| l.is_a? ItemLine}}
  overdued_take_backs = overdued_take_backs.select { |x| x.date < Date.today } if arg1
  overdued_take_back = overdued_take_backs.sample
  @line_id = overdued_take_back.contract_lines.where(type: "ItemLine").sample.id
  visit manage_take_back_path(@current_inventory_pool, overdued_take_back.user)
  expect(has_selector?(".line[data-id='#{@line_id}']")).to be true
end

def open_inspection_for_line(line_id)
  within(".line[data-id='#{line_id}'] .multibutton") do
    find(".dropdown-toggle").click
    find(".dropdown-holder .dropdown-item", text: _("Inspect")).click
  end
  find(".modal")
end

Dann /^markiere ich den Gegenstand als nicht ausleihbar$/ do
  open_inspection_for_line(@line_id)
  find("select[name='is_borrowable']").select "Nicht ausleihbar"
  find(".modal button[type='submit']").click
end

Dann /^markiere ich den Gegenstand als defekt$/ do
  open_inspection_for_line(@line_id)
  find("select[name='is_broken']").select "Defekt"
  find(".modal button[type='submit']").click
end

Dann /^markiere ich den Gegenstand als unvollständig$/ do
  open_inspection_for_line(@line_id)
  find("select[name='is_incomplete']").select "Unvollständig"
  find(".modal button[type='submit']").click
end

Angenommen /^eine Gegenstand ist defekt$/ do
  if @event == "hand_over"
    @item = @current_inventory_pool.items.in_stock.broken.sample
    step 'I add an item to the hand over'
    @line_id = find("input[value='#{@item.inventory_code}']").find(:xpath, "ancestor::div[@data-id]")["data-id"]
  elsif  @event == "take_back"
    @line_id = find(".line[data-line-type='item_line']", match: :first)[:"data-id"]
    step 'markiere ich den Gegenstand als defekt'
  end
end

Angenommen /^eine Gegenstand ist unvollständig$/ do
  if @event == "hand_over"
    @item = @current_inventory_pool.items.in_stock.incomplete.sample
    step 'I add an item to the hand over'
    @line_id = find("input[value='#{@item.inventory_code}']").find(:xpath, "ancestor::div[@data-id]")["data-id"]
  elsif  @event == "take_back"
    @line_id = find(".line[data-line-type='item_line']", match: :first)[:"data-id"]
    step 'markiere ich den Gegenstand als unvollständig'
  end
end

Dann /^sehe ich auf der Linie des betroffenen Gegenstandes die Auszeichnung von Problemen$/ do
  target = find(".line[data-id='#{@line_id}'] .emboss.red")
  hover_for_tooltip target
  @problems = []
  @problems << find(".tooltipster-default .tooltipster-content", text: /\w/).text
end
