# encoding: utf-8

Angenommen /^ich editiere eine Bestellung$/ do
  @event = "order"
  step 'I open a contract for acknowledgement'
end

Angenommen /^ich mache eine Rücknahme$/ do
  @event = "take_back"
  step 'I open a take back'
end

Angenommen /^ich mache eine Aushändigung$/ do
  @event = "hand_over"
  step 'I open a hand over'
end

Angenommen /^eine Model ist nichtmehr verfügbar$/ do
  if @event=="order" or @event=="hand_over"
    @entity = if @order
      @order
    else
      @customer.get_approved_contract(@ip)
    end
    @max_before = @entity.lines.first.model.availability_in(@entity.inventory_pool).maximum_available_in_period_summed_for_groups(@entity.lines.first.start_date, @entity.lines.first.end_date, @entity.lines.first.group_ids)
    step 'I add so many lines that I break the maximal quantity of an model'
  else
    @model = @contract.models.first
    visit backend_inventory_pool_user_hand_over_path(@contract.inventory_pool, @customer)
    @max_before = @contract.lines.first.model.availability_in(@contract.inventory_pool).maximum_available_in_period_summed_for_groups(@contract.lines.first.start_date, @contract.lines.first.end_date, @contract.lines.first.group_ids)
    step 'I add so many lines that I break the maximal quantity of an model'
    visit backend_inventory_pool_user_take_back_path(@contract.inventory_pool, @customer)
  end
  page.has_selector? ".line.error", text: @model.name
  @lines = all(".line.error", :text => @model.name)
  @lines.size.should > 0
end

Dann /^sehe ich auf den beteiligten Linien die Auszeichnung von Problemen$/ do
  @problems = []

  @lines.each do |line|
    find(".line[data-id='#{line["data-id"]}'] .problems").hover
    @problems << find(".tip", match: :first).text
  end
  @reference_line = @lines.first
  @reference_problem = @problems.first
  @line = ContractLine.find @reference_line["data-id"]
  @av = @line.model.availability_in(@line.inventory_pool)
end

Dann /^das Problem wird wie folgt dargestellt: "(.*?)"$/ do |format|
  regexp = if format == "Nicht verfügbar 2(3)/7"
     /#{_("Not available")} -*\d\(-*\d\)\/\d/
  elsif format == "Gegenstand nicht ausleihbar"
    /_("Item not borrowable")/
  elsif format == "Gegenstand ist defekt"
    /_("Item is defective")/
  elsif format == "Gegenstand ist unvollständig"
    /_("Item is incomplete")/
  elsif format == "Überfällig seit 6 Tagen"
     /(Überfällig seit \d+ (Tagen|Tag)|#{_("Overdue")} #{_("since")} \d+ (days|day))/
  end
  @problems.each do |problem|
    problem.match(regexp).should_not be_nil
  end
end

Dann /^"(.*?)" sind verfügbar für den Kunden$/ do |arg1|
  max = if [:unsubmitted, :submitted].include? @line.contract.status
    @max_before + @quantity_added
  elsif [:approved, :signed].include? @line.contract.status
    @av.maximum_available_in_period_summed_for_groups(@line.start_date, @line.end_date, @line.group_ids) + @line.contract.lines.where(:start_date => @line.start_date, :end_date => @line.end_date, :model_id => @line.model).size
  else
    @max_before - @quantity_added
  end
  @reference_problem.match(/#{max}\(/).should_not be_nil
end

Dann /^"(.*?)" sind insgesamt verfügbar$/ do |arg1|
  max = @av.maximum_available_in_period_summed_for_groups(@line.start_date, @line.end_date, @ip.group_ids)
  if [:unsubmitted, :submitted].include? @line.contract.status
    max += @line.contract.lines.where(:start_date => @line.start_date, :end_date => @line.end_date, :model_id => @line.model).size
  else
    max += @line.quantity
  end
  @reference_problem.match(/\(#{max}/).should_not be_nil
end

Dann /^"(.*?)" sind total im Pool bekannt \(ausleihbar\)$/ do |arg1|
  @reference_problem.match("/#{@line.model.items.scoped_by_inventory_pool_id(@line.inventory_pool).borrowable.size}").should_not be_nil
end

Angenommen /^eine Gegenstand ist nicht ausleihbar$/ do
  if @event == "hand_over"
    @item = @ip.items.unborrowable.first
    step 'I add an item to the hand over'
    @line_id = find(".line.assigned", match: :first)[:"data-id"]
  elsif @event === "take_back"
    @line_id = find(".item_line", match: :first)[:"data-id"]
    step 'markiere ich den Gegenstand als nicht ausleihbar'
  end
end

Angenommen /^ich mache eine Rücknahme eines verspäteten Gegenstandes$/ do
  @event = "take_back"
  @ip = @current_user.managed_inventory_pools.first
  overdued_take_back = @ip.visits.take_back.detect{|x| x.date < Date.today}
  @line_id = overdued_take_back.lines.first.id
  visit backend_inventory_pool_user_take_back_path(@ip, overdued_take_back.user)
  page.should have_selector(".line[data-id='#{@line_id}']")
end

Dann /^markiere ich den Gegenstand als nicht ausleihbar$/ do
  find(".line[data-id='#{@line_id}'] .actions .trigger").hover
  find(".line[data-id='#{@line_id}'] .actions .button", text: _("Inspect")).click
  page.should have_selector(".dialog")
  first("select[name='flags[is_borrowable]']").select "Nicht ausleihbar"
  first(".dialog .navigation button[type='submit']").click
  page.should have_selector(".notification")
end

Dann /^markiere ich den Gegenstand als defekt$/ do
  find(".line[data-id='#{@line_id}'] .actions .trigger").hover
  find(".line[data-id='#{@line_id}'] .actions .button", text: _("Inspect")).click
  page.should have_selector(".dialog")
  first("select[name='flags[is_broken]']").select "Defekt"
  first(".dialog .navigation button[type='submit']").click
  page.should have_selector(".notification")
end

Dann /^markiere ich den Gegenstand als unvollständig$/ do
  find(".line[data-id='#{@line_id}'] .actions .trigger").hover
  find(".line[data-id='#{@line_id}'] .actions .button", text: _("Inspect")).click
  page.should have_selector(".dialog", :visible => true)
  first("select[name='flags[is_incomplete]']").select "Unvollständig"
  first(".dialog .navigation button[type='submit']").click
  page.should have_selector(".notification")
end

Angenommen /^eine Gegenstand ist defekt$/ do
  if @event == "hand_over"
    @item = @ip.items.broken.first
    step 'I add an item to the hand over'
    @line_id = find(".line.assigned", match: :first)[:"data-id"]
  elsif  @event == "take_back"
    @line_id = find(".item_line", match: :first)[:"data-id"]
    step 'markiere ich den Gegenstand als defekt'
  end
end

Angenommen /^eine Gegenstand ist unvollständig$/ do
  if @event == "hand_over"
    @item = @ip.items.incomplete.first
    step 'I add an item to the hand over'
    @line_id = find(".line.assigned", match: :first)[:"data-id"]
  elsif  @event == "take_back"
    @line_id = find(".item_line", match: :first)[:"data-id"]
    step 'markiere ich den Gegenstand als unvollständig'
  end
end

Dann /^sehe ich auf der Linie des betroffenen Gegenstandes die Auszeichnung von Problemen$/ do
  find(".line[data-id='#{@line_id}'] .problems", :visible => true).hover
  find(".tip", :visible => true).text.match(/\w/).should be_true
  @problems = []
  @problems << first(".tip").text
end
