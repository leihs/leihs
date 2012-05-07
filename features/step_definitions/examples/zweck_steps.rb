# -*- encoding : utf-8 -*-

Wenn /^ein Zweck gespeichert wird ist er unabhängig von einer Bestellung$/ do
  purpose = FactoryGirl.create :purpose
  lambda{ purpose.order }.should raise_error(NoMethodError)
end

Wenn /^jeder Eintrag einer Bestellung referenziert auf einen Zweck$/ do
  FactoryGirl.create(:order_with_lines).lines.each do |line|
    line.purpose.should be_a_kind_of Purpose
  end
end

Wenn /^jeder Eintrag eines Vertrages kann auf einen Zweck referenzieren$/ do
  FactoryGirl.create(:contract_with_lines).lines.each do |line|
    line.purpose = FactoryGirl.create :purpose
    line.purpose.should be_a_kind_of Purpose
  end
end

Wenn /^ich eine Bestellung genehmige$/ do
  step 'I open an order for acknowledgement'
end

Dann /^sehe ich den Zweck$/ do
  page.should have_content @order.lines.first.purpose.description
end

Wenn /^ich eine Aushändigung mache$/ do
  step 'I open a hand over'
end

Dann /^sehe ich auf jeder Zeile den zugewisenen Zweck$/ do
  @customer.contracts.unsigned.first.lines.each_with_index do |line, i|
    all(".line")[i].should have_content line.model.name
    all(".line")[i].should have_content line.purpose.description[0..10]
  end
end

Dann /^kann ich den Zweck editieren$/ do
  find(".button", :text => "Edit Purpose").click
  wait_until{ find(".dialog #purpose") }
  @new_purpose_description = "Benötigt für die Sommer-Austellung"
  find(".dialog #purpose").set @new_purpose_description
  find(".dialog button[type=submit]").click
  wait_until { all(".dialog", :visible => true).size == 0 }
  @order.reload.lines.first.purpose.description.should == @new_purpose_description
  find("section.purpose").should have_content @new_purpose_description 
end

Dann /^kann ich einen Zweck hinzufügen$/ do
  find(".line .select input").click
  find("#hand_over_button").click
  wait_until { find(".dialog .purpose") }
  find(".purpose .button").click
  find("#purpose")
end

Wenn /^keine der ausgewählten Gegenstände hat einen Zweck angegeben$/ do
  step 'I add an item to the hand over by providing an inventory code and a date range'
  step 'I add an option to the hand over by providing an inventory code and a date range'
end

Dann /^werde ich beim Aushändigen darauf hingewiesen einen Zweck anzugeben$/ do
  find("#hand_over_button").click
  wait_until{ find(".dialog .button") }
  find(".purpose #purpose")
end

Dann /^erst wenn ich einen Zweck angebebe$/ do
  find(".dialog .button[type=submit]", :text => "Hand Over").click
  wait_until { find(".notification") }
  find(".dialog #purpose").set "The purpose for this hand over"
end

Dann /^kann ich die Aushändigung durchführen$/ do
  find(".dialog .button[type=submit]", :text => "Hand Over").click
  wait_until { all(".loading", :visible => true).size == 0 }
  binding.pry
end