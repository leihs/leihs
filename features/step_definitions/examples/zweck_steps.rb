# -*- encoding : utf-8 -*-

Wenn /^ein Zweck gespeichert wird ist er unabhängig von einer Bestellung$/ do
  purpose = FactoryGirl.create :purpose
  lambda{ purpose.contract }.should raise_error(NoMethodError)
end

Wenn /^jeder Eintrag einer abgeschickten Bestellung referenziert auf einen Zweck$/ do
  FactoryGirl.create(:contract_with_lines, status: :submitted).lines.each do |line|
    line.purpose.should be_a_kind_of Purpose
  end
end

Wenn /^jeder Eintrag eines Vertrages kann auf einen Zweck referenzieren$/ do
  FactoryGirl.create(:contract_with_lines).lines.each do |line|
    line.purpose = FactoryGirl.create :purpose
    line.purpose.should be_a_kind_of Purpose
  end
end

Wenn /^ich eine Bestellung editiere$/ do
  contract_id = find(".contract.line", match: :first)["data-id"].to_i
  @contract = Contract.find(contract_id)
  visit backend_inventory_pool_acknowledge_path(@contract.inventory_pool, @contract)
end

Dann /^sehe ich den Zweck$/ do
  if @contract.lines.first.purpose
    page.should have_content @contract.lines.first.purpose.description
  end
end

Wenn /^ich eine Aushändigung mache$/ do
  step 'I open a hand over'
end

Dann /^sehe ich auf jeder Zeile den zugewisenen Zweck$/ do
  @customer.contracts.approved.first.lines.each do |line|
    find(".line[data-id='#{line.id}']").should have_content line.model.name
    find(".line[data-id='#{line.id}']").should have_content line.purpose.description[0..10]
  end
end

Dann /^kann ich den Zweck editieren$/ do
  find(".button", :text => /(Edit Purpose|Zweck editieren)/).click
  @new_purpose_description = "Benötigt für die Sommer-Austellung"
  find(".dialog #purpose").set @new_purpose_description
  find(".dialog button[type=submit]").click
  page.should_not have_selector(".dialog")
  @contract.reload.lines.first.purpose.description.should == @new_purpose_description
  find("section.purpose").should have_content @new_purpose_description
end

Dann /^kann ich einen Zweck hinzufügen$/ do
  step 'I click an inventory code input field of an item line'
  step 'I select one of those'
  find("#hand_over_button").click
  page.should have_selector(".dialog .purpose")
  find(".purpose .button").click
  page.should have_selector("#purpose")
end

Wenn /^keine der ausgewählten Gegenstände hat einen Zweck angegeben$/ do
  step 'I add an item to the hand over by providing an inventory code and a date range'
  step 'I add an option to the hand over by providing an inventory code and a date range'
end

Dann /^werde ich beim Aushändigen darauf hingewiesen einen Zweck anzugeben$/ do
  find("#hand_over_button").click
  page.has_selector?(".dialog .button")
  page.has_selector?(".purpose #purpose")
end

Dann /^erst wenn ich einen Zweck angebebe$/ do
  find(".dialog .button[type=submit]", :text => /(Hand Over|Aushändigen)/).click
  page.has_selector?(".notification")
  find(".dialog #purpose").set "The purpose for this hand over"
end

Dann /^kann ich die Aushändigung durchführen$/ do
  signed_contracts_size = @customer.contracts.signed.size
  find(".dialog .button[type=submit]", :text => /(Hand Over|Aushändigen)/)
  step 'I click hand over inside the dialog'
  sleep(0.88)
  @customer.contracts.signed.size.should > signed_contracts_size
end

Wenn /^einige der ausgewählten Gegenstände hat keinen Zweck angegeben$/ do
  step 'I click an inventory code input field of an item line'
  step 'I select one of those'
  step 'I add an item to the hand over by providing an inventory code and a date range'
  step 'I add an option to the hand over by providing an inventory code and a date range'
end

Dann /^muss ich keinen Zweck angeben um die Aushändigung durchzuführen$/ do
  find("#hand_over_button").click
  page.should have_selector(".dialog .button")
  step 'kann ich die Aushändigung durchführen'
end

Wenn /^ich einen Zweck angebe$/ do
  find("#hand_over_button").click
  page.should have_selector(".dialog .button")
  find(".purpose .button").click
  @added_purpose = "Another Purpose"
  find("#purpose").set @added_purpose
  @approved_lines = @customer.contracts.approved.first.lines
  step 'kann ich die Aushändigung durchführen'
end

Dann /^wird nur den Gegenständen ohne Zweck der angegebene Zweck zugewiesen$/ do
  @approved_lines.select{|l| l.purpose.blank?}.each do |line|
    line.purpose.description.should == @added_purpose
  end
end

Wenn /^alle der ausgewählten Gegenstände haben einen Zweck angegeben$/ do
  @contract = @customer.contracts.approved.first
  @contract.lines.where(ContractLine.arel_table[:start_date].lteq(Date.today)).each do |line|
    @item_line = line
    step 'I select one of those'
  end
  all(".line.assigned .select input").each do |select|
    select.click unless select.selected?
  end
  find("#hand_over_button").click
  page.should have_selector(".dialog .purpose")
end

Dann /^kann ich keinen weiteren Zweck angeben$/ do
  page.should_not have_selector(".dialog .purpose button", :visible => true)
end
