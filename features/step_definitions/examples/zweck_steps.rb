# -*- encoding : utf-8 -*-

Wenn /^ein Zweck gespeichert wird ist er unabhängig von einer Bestellung$/ do
  purpose = FactoryGirld.create :purpose
  lambda{ purpose.order  }.should raise(NoMethodError)
end

Wenn /^jeder Eintrag einer Bestellung referenziert einen Zweck$/ do
  contract = FactoryGirl.create :contract_with_lines
  contract.lines.each do |line|
    line.should
  end
end

Wenn /^jeder Eintrag eines Vertrages refereziert auf einen Zweck$/ do
  pending # express the regexp above with the code you wish you had
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