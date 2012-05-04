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

Wenn /^ich eine Bestellung genehmigen muss sehe ich den Zweck$/ do
  pending # express the regexp above with the code you wish you had
end

Wenn /^ich eine Aushändigung mache sehe ich auf jeder Zeile den zugewisenen Zweck$/ do
  pending # express the regexp above with the code you wish you had
end

Wenn /^ich eine Bestellung genehmige dann kann ich den Zweck editieren\.$/ do
  pending # express the regexp above with the code you wish you had
end

Wenn /^ich eine Aushändigung durchführe$/ do
  pending # express the regexp above with the code you wish you had
end

Dann /^kann ich einen zusätzlichen Zweck hinzufügen$/ do
  pending # express the regexp above with the code you wish you had
end