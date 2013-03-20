# -*- encoding : utf-8 -*-

Angenommen /^man editiert einen Gegenstand$/ do
  @ip = @current_user.managed_inventory_pools
  visit backend_inventory_pool_inventory_path(@ip)
  find(".model.line .toggle .text", :text => /(1|2|3|4|5|6)/).click
  item_line = find(".item.line")
  @item = Item.find_by_inventory_code(item_line.find(".inventory_code").text)
  item_line.find(".actions .button", :text => /(Editieren|Edit)/i).click
end

Dann /^muss der "(.*?)" unter "(.*?)" ausgewählt werden$/ do |key, section|
  section = find("h2", :text => section).find(:xpath, "./..")
  field = section.find("h3", :text => key).find(:xpath, "./..")
  field[:class][/required/].should_not be_nil
end

Wenn /^"(.*?)" bei "(.*?)" ausgewählt ist muss auch "(.*?)" angegeben werden$/ do |value, key, newkey|
  field = find("h3", :text => key).find(:xpath, "./..")
  field.find("label", :text => value).click
  newfield = find("h3", :text => newkey).find(:xpath, "./..")
  newfield[:class][/required/].should_not be_nil
end

Dann /^sind alle Pflichtfelder mit einem Stern gekenzeichnet$/ do
  all(".field.required", :visible => true).each {|field| field.text[/\*/].should_not be_nil}
  all(".field:not(.required)").each {|field| field.text[/\*/].should be_nil}
end

Wenn /^ein Pflichtfeld nicht ausgefüllt\/ausgewählt ist, dann lässt sich der Gegenstand nicht speichern$/ do
  find(".field.required textarea").set("")
  find(".field.required input[type='text']").set("")
  find(".content_navigation button[type=submit]").click
  find(".content_navigation button[type=submit]")
  @item.to_json.should == @item.reload.to_json
end

Wenn /^der Benutzer sieht eine Fehlermeldung$/ do
  find(".notification.error")
end

Wenn /^die nicht ausgefüllten\/ausgewählten Pflichtfelder sind rot markiert$/ do
  all(".required.field", :visible => true).each do |field|
    if field.all("input[type=text]").any?{|input| input.value == 0} or 
      field.all("textarea").any?{|textarea| textarea.value == 0} or
      field.all("input[type=radio]").all?{|input| not input.checked?}
        field[:class][/invalid/].should_not be_nil
    end
  end
end

Dann /^sehe ich die Felder in folgender Reihenfolge:$/ do |table|
  values = table.raw.map do |x|
    x.first.gsub(/^\-\ |\ \-$/, '')
  end
  (page.text =~ Regexp.new(values.join('.*'), Regexp::MULTILINE)).should_not be_nil
end
