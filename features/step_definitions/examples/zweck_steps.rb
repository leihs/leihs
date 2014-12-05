# -*- encoding : utf-8 -*-

Wenn /^ein Zweck gespeichert wird ist er unabhängig von einer Bestellung$/ do
  purpose = FactoryGirl.create :purpose
  expect { purpose.contract }.to raise_error(NoMethodError)
end

Wenn /^jeder Eintrag einer abgeschickten Bestellung referenziert auf einen Zweck$/ do
  FactoryGirl.create(:contract_with_lines, status: :submitted).lines.each do |line|
    expect(line.purpose.is_a?(Purpose)).to be true
  end
end

Wenn /^jeder Eintrag eines Vertrages kann auf einen Zweck referenzieren$/ do
  FactoryGirl.create(:contract_with_lines).lines.each do |line|
    line.purpose = FactoryGirl.create :purpose
    expect(line.purpose.is_a?(Purpose)).to be true
  end
end

Wenn /^ich eine Bestellung editiere$/ do
  @contract = @current_inventory_pool.contracts.submitted.sample
  @user = @contract.user
  step "ich die Bestellung editiere"
end

Dann /^sehe ich den Zweck$/ do
  if @contract.lines.first.purpose
    expect(has_content?(@contract.lines.first.purpose.description)).to be true
  end
end

Dann /^sehe ich auf jeder Zeile den zugewisenen Zweck$/ do
  @customer.get_approved_contract(@current_inventory_pool).lines.each do |line|
    target = find(".line[data-id='#{line.id}'] [data-tooltip-template*='purpose']")
    hover_for_tooltip target
    find(".tooltipster-default .tooltipster-content", text: line.purpose.description)
  end
end

Dann /^kann ich den Zweck editieren$/ do
  find(".button", :text => /(Edit Purpose|Zweck editieren)/).click
  @new_purpose_description = "Benötigt für die Sommer-Austellung"
  find(".modal textarea[name='purpose']").set @new_purpose_description
  find(".modal button[type=submit]").click
  find("#purpose", text: @new_purpose_description)
  expect(@contract.reload.lines.first.purpose.description).to eq @new_purpose_description
end

Dann /^kann ich einen Zweck hinzufügen$/ do
  step 'I click an inventory code input field of an item line'
  step 'I select one of those'
  find(".multibutton .button[data-hand-over-selection]").click
  find(".purpose .button").click
  find("#purpose")
end

Wenn /^keine der ausgewählten Gegenstände hat einen Zweck angegeben$/ do
  step 'I add an item to the hand over by providing an inventory code'
  step 'I add an option to the hand over by providing an inventory code and a date range'
  step 'I edit the timerange of the selection'
  step "ich setze das Startdatum im Kalendar auf '#{I18n.l(Date.today)}'"
  step 'I save the booking calendar'
  step 'the booking calendar is closed'
end

Dann /^werde ich beim Aushändigen darauf hingewiesen einen Zweck anzugeben$/ do
  find(".multibutton .button[data-hand-over-selection]").click
  within ".modal" do
    find(".button", match: :first)
    find("#purpose")
  end
end

Dann /^erst wenn ich einen Zweck angebebe$/ do
  within ".modal" do
    find(".button.green[data-hand-over]", :text => _("Hand Over")).click
    find("#error")
    find("#purpose").set "The purpose for this hand over"
  end
end

Dann /^kann ich die Aushändigung durchführen$/ do
  signed_contracts_size = @customer.contracts.signed.size
  step 'I click hand over inside the dialog'
  expect(@customer.contracts.signed.size).to be > signed_contracts_size
end

Dann /^muss ich keinen Zweck angeben um die Aushändigung durchzuführen$/ do
  step 'I edit the timerange of the selection'
  step "ich setze das Startdatum im Kalendar auf '#{I18n.l(Date.today)}'"
  step 'I save the booking calendar'
  step 'the booking calendar is closed'
  find(".multibutton .button[data-hand-over-selection]").click
  find(".modal.ui-shown")
  step 'kann ich die Aushändigung durchführen'
end

Wenn /^ich einen Zweck angebe$/ do
  step 'I edit the timerange of the selection'
  step "ich setze das Startdatum im Kalendar auf '#{I18n.l(Date.today)}'"
  step 'I save the booking calendar'
  step 'the booking calendar is closed'
  find(".multibutton .button[data-hand-over-selection]").click
  find("#add-purpose").click
  @added_purpose = "Another Purpose"
  find("#purpose").set @added_purpose
  @approved_lines = @customer.get_approved_contract(@current_inventory_pool).lines
  step 'kann ich die Aushändigung durchführen'
end

Dann /^wird nur den Gegenständen ohne Zweck der angegebene Zweck zugewiesen$/ do
  @approved_lines.select{|l| l.purpose.blank?}.each do |line|
    expect(line.purpose.description).to eq @added_purpose
  end
end

Wenn /^alle der ausgewählten Gegenstände haben einen Zweck angegeben$/ do
  @contract = @customer.get_approved_contract(@current_inventory_pool)
  lines = @contract.lines
  lines.each do |line|
    @item_line = line
    begin
      step 'I select one of those'
    rescue
      # if we ran out of available items, and an Capybara::Element not found exception was raised, just ensure that all the selected and assigned contract lines so far, have a purpose
      expect(lines.reload.select(&:item).all?(&:purpose)).to be true
      break
    end
  end

  # select all lines if no one is selected yet
  if all("input[type='checkbox']:checked").empty?
    step "I select all lines selecting all linegroups"
  end
  # ensure that only lines with assigned items are selected before continuing with the test
  lines.reload.select{|l| !l.item}.each do |l|
    cb = find(".line[data-id='#{l.id}'] input[type='checkbox']")
    cb.click if cb.checked?
  end

  step 'I edit the timerange of the selection'
  step "ich setze das Startdatum im Kalendar auf '#{I18n.l(Date.today)}'"
  step 'I save the booking calendar'
  step 'the booking calendar is closed'

  within "#lines" do
    lines = lines.select {|line| line.item and find(".line[data-id='#{line.id}'] input[type='checkbox'][data-select-line]").checked? }
  end

  find(".multibutton .button[data-hand-over-selection]").click
  within(".modal") do
    lines.each do |line|
      find(".row", match: :first, text: line.purpose.to_s)
    end
  end
end

Dann /^kann ich keinen weiteren Zweck angeben$/ do
  expect(has_no_selector?(".modal .purpose button", :visible => true)).to be true
end
