# -*- encoding : utf-8 -*-


#When(/^sehe ich unterhalb der Kategorien einen Link zur Liste der Vorlagen$/) do
Then(/^I see a link to the templates underneath the categories$/) do
  find("a[href='#{borrow_templates_path}'][title='#{_("Borrow template")}']", match: :first)
end

#When(/^ich schaue mir die Liste der Vorlagen an$/) do
When(/^I am listing templates in the borrow section$/) do
  visit borrow_templates_path
end

#Dann(/^sehe ich die Vorlagen$/) do
Then(/^I see the templates$/) do
  @current_user.templates.each do |template|
    find("a[href='#{borrow_template_path(template)}']", match: :first, text: template.name)
  end
end

#Dann(/^die Vorlagen sind alphabetisch nach Namen sortiert$/) do
Then(/^the templates are sorted alphabetically by name$/) do
  all_names = all(".separated-top > a[href*='#{borrow_templates_path}']").map {|x| x.text.strip }
  expect(all_names.sort).to eq all_names
  expect(all_names.count).to eq @current_user.templates.count
end

#When(/^ich kann eine der Vorlagen detailliert betrachten$/) do
Then(/^I can look at one of the templates in detail$/) do
  template = @current_user.templates.sample
  find("a[href='#{borrow_template_path(template)}']", match: :first, text: template.name).click
  find("nav a[href='#{borrow_template_path(template)}']", match: :first)
end

#When(/^ich sehe mir eine Vorlage an$/) do
When(/^I am looking at a template$/) do
  @template = @current_user.templates.find do |t|
    # choose a template, whose all models provide some borrowable quantity (> 0) considering all customer's groups from all his inventory pools
    t.models.all? do |m|
      t.inventory_pools.map do |ip|
        m.total_borrowable_items_for_user(@current_user, ip)
      end.max > 0
    end
  end

  visit borrow_template_path(@template)
  find("nav a[href='#{borrow_template_path(@template)}']", match: :first)
end

#Dann(/^sehe ich alle Modelle, die diese Vorlage beinhaltet$/) do
Then(/^I see all models that template contains$/) do
  @template.model_links.each do |model_link|
    find(".line", match: :prefer_exact, text: model_link.model.name).find("input[name='lines[][quantity]'][value='#{model_link.quantity}']")
  end
end

#Dann(/^die Modelle in dieser Vorlage sind alphabetisch sortiert$/) do
Then(/^the models in that template are ordered alphabetically$/) do
  all_names = all(".separated-top > .row.line").map {|x| x.text.strip }
  expect(all_names.sort).to eq all_names
  expect(all_names.count).to eq @template.models.count
end

#When(/^ich sehe für jedes Modell die Anzahl Gegenstände dieses Modells, welche die Vorlage vorgibt$/) do
Then(/^for each model I see the quantity as specified by the template$/) do
  @template.model_links.each do |model_link|
    find(".row", match: :first, text: model_link.model.name).find("input[name='lines[][quantity]'][value='#{model_link.quantity}']", match: :first)
  end
end

#When(/^ich kann die Anzahl jedes Modells verändern, bevor ich den Prozess fortsetze$/) do
When(/^I can modify the quantity of each model before ordering$/) do
  @model_link = @template.model_links.order("RAND()").first
  find(".row", match: :first, text: @model_link.model.name).find("input[name='lines[][quantity]'][value='#{@model_link.quantity}']", match: :first).set rand(10)
end

#When(/^ich kann höchstens die maximale Anzahl an verfügbaren Geräten eingeben$/) do
Then(/^I can specify at most the maximum available quantity per model$/) do
  max = find(".row", match: :first, text: @model_link.model.name).find("input[name='lines[][quantity]']", match: :first)[:max].to_i
  find(".row", match: :first, text: @model_link.model.name).find("input[name='lines[][quantity]']", match: :first).set max+1
  expect(find(".row", match: :first, text: @model_link.model.name).find("input[name='lines[][quantity]']", match: :first).value.to_i).to eq max
end

#When(/^sehe ich eine auffällige Warnung sowohl auf der Seite wie bei den betroffenen Modellen$/) do
Then(/^I see a warning on the page itself and on every affected model$/) do
  find(".emboss.red", match: :first, text: _("The highlighted entries are not accomplishable for the intended quantity."))
  find(".separated-top .row.line .line-info.red", match: :first)
end

# Dann(/^kann ich Start\- und Enddatum einer potenziellen Bestellung angeben$/) do
#   @start_date = Date.tomorrow
#   @end_date = Date.tomorrow + 4.days
#   find("#start_date", match: :first).set I18n.localize @start_date
#   find("#end_date", match: :first).set I18n.localize @end_date
# end

#Dann(/^ich kann im Prozess weiterfahren zur Verfügbarkeitsanzeige der Vorlage$/) do
Then(/^I can follow the process to the availability display of the template$/) do
  find(".green[type='submit']", match: :first).click
end

#Dann(/^alle Einträge erhalten das ausgewählte Start\- und Enddatum$/) do
Then(/^all entries get the chosen start and end date$/) do
  find(".headline-m", match: :first, text: I18n.localize(@start_date))
  all(".line-col.col1of9.text-align-left").each do |date|
    date = date.text.split(" ").last
    expect(date).to eq I18n.localize(@end_date)
  end
end

#When(/^in dieser Vorlage hat es Modelle, die nicht genügeng Gegenstände haben, um die in der Vorlage gewünschte Anzahl zu erfüllen$/) do
When(/^this template contains models that don't have enough items to satisfy the quantity required by the template$/) do
  @template = @current_user.templates.detect {|t| not t.accomplishable?(@current_user) }
  visit borrow_template_path(@template)
  find("nav a[href='#{borrow_template_path(@template)}']", match: :first)
end

#When(/^ich sehe die Verfügbarkeit einer Vorlage$/) do
#  step "ich sehe mir eine Vorlage an"
#  step "ich kann im Prozess weiterfahren zur Verfügbarkeitsanzeige der Vorlage"
#end

#When(/^ich sehe die Verfügbarkeit einer nicht verfügbaren Vorlage$/) do
When(/^I see the availability of a template that has items that are not available$/) do
  #step "in dieser Vorlage hat es Modelle, die nicht genügeng Gegenstände haben, um die in der Vorlage gewünschte Anzahl zu erfüllen"
  step "this template contains models that don't have enough items to satisfy the quantity required by the template"
  #step "ich kann im Prozess weiterfahren zur Verfügbarkeitsanzeige der Vorlage"
  step 'I can follow the process to the availability display of the template'
  find("[type='submit']", match: :first).click
end

#Angenommen(/^einige Modelle sind nicht verfügbar$/) do
Given(/^some models are not available$/) do
  find(".emboss.red", match: :first, text: _("Please solve the conflicts for all highlighted lines in order to continue."))
  find(".separated-top .row.line .line-info.red", match: :first)
end

#Dann(/^kann ich diejenigen Modelle, die verfügbar sind, gesamthaft einer Bestellung hinzufügen$/) do
Then(/^I can add those models which are available to an order all at once$/) do
  expect(has_selector?(".separated-top .row.line .line-info.red")).to be true
  @unavailable_model_ids = all(".separated-top .row.line .line-info.red").map {|x| x.first(:xpath, "./..").find("input[name='lines[][model_id]']", match: :first, visible: false).value.to_i}
  @unavailable_model_ids -= @current_user.contract_lines.unsubmitted.map(&:model_id).uniq
  find(".button.green.dropdown-toggle", match: :first).click
  expect(has_content?(_("Continue with available models only"))).to be true
  find("[name='force_continue']", match: :first, :text => _("Continue with available models only")).click
end

#Dann(/^die restlichen Modelle werden verworfen$/) do
Then(/^the other models are ignored$/) do
  expect(@unavailable_model_ids - @current_user.contract_lines.unsubmitted.reload.map(&:model_id).uniq).to eq @unavailable_model_ids
end

#Dann(/^die Modelle sind innerhalb eine Gruppe alphabetisch sortiert$/) do
Then(/^the models are sorted alphabetically within a group$/) do
  expect(all(".row.line .col6of10").map(&:text)).to eq @template.models.sort.map(&:name)
end

#Dann(/^sind diejenigen Modelle hervorgehoben, die zu diesem Zeitpunkt nicht verfügbar sind$/) do
Then(/^those models are highlighted that are no longer available at this time$/) do
  within "#template-lines" do
    all(".row.line").each do |line|
      line.find(".line-info.red", match: :first)
    end
  end
end

#Dann(/^ich kann Modelle aus der Ansicht entfernen$/) do
Then(/^I can remove the models from the view$/) do
  within(".row.line", match: :first) do
    if has_selector? ".multibutton .dropdown-toggle"
      find(".multibutton .dropdown-toggle").click
    end
    find(".red", text: _("Delete")).click
  end
  page.driver.browser.switch_to.alert.accept rescue nil
end

#Dann(/^ich kann die Anzahl der Modelle ändern$/) do
Then(/^I can change the quantity of the models$/) do
  @model = Model.find_by_name(find(".row.line .col6of10").text)
  find(".line .button", match: :first).click
  find("#booking-calendar .fc-day-content", match: :first)
  find("#booking-calendar-quantity").set 1
end

def select_available_not_closed_date(as = :start, from = Date.today)
  current_date = from
  while all(".available:not(.closed)[data-date='#{current_date.to_s}']").empty? do
    before_date = current_date
    current_date += 1.day
    find(".fc-button-next").click if before_date.month < current_date.month
  end
  step "I set the %s in the calendar to '#{I18n::l(current_date)}'" % (as == :start ? "start date" : "end date")
  current_date
end

#Dann(/^ich kann das Zeitfenster für die Verfügbarkeitsberechnung einzelner Modelle ändern$/) do
Then(/^I can change the time range for the availability calculatin of particular models$/) do
  start_date = select_available_not_closed_date
  select_available_not_closed_date(:end, start_date)
  step "I save the booking calendar"
end

#Wenn(/^ich sämtliche Verfügbarkeitsprobleme gelöst habe$/) do
When(/^I have solved all availability problems$/) do
  expect(has_no_selector?(".line-info.red")).to be true
end

#Dann(/^kann ich im Prozess weiterfahren und alle Modelle gesamthaft zu einer Bestellung hinzufügen$/) do
Then(/^I can continue in the process and add all models to the order at once$/) do
  find(".button.green", match: :first, text: _("Add to order")).click
  find("#current-order-show", match: :first)
  expect(@current_user.contract_lines.unsubmitted.map(&:model)).to include @model
end

#Angenommen(/^ich sehe die Verfügbarkeit einer Vorlage, die nicht verfügbare Modelle enthält$/) do
Given(/^I am looking at the availability of a template that contains unavailable models$/) do
  step "I am looking at a template"
  find("[type='submit']", match: :first).click
  date = Date.today
  while @template.inventory_pools.first.is_open_on?(date) do
   date += 1.day 
  end
  find("#start_date").set I18n::localize(date)
  find("#end_date").set I18n::localize(date)
  step 'I can follow the process to the availability display of the template'
end

#Dann(/^ich muss den Prozess zur Datumseingabe fortsetzen$/) do
Then(/^I have to continue the process of specifying start and end dates$/) do
  find("[type='submit']", match: :first).click
  within "#template-select-dates" do
    find("#start_date")
    find("#end_date")
  end
end

#Angenommen(/^ich habe die Mengen in der Vorlage gewählt$/) do
Given(/^I have chosen the quantities mentioned in the template$/) do
  #step "ich sehe mir eine Vorlage an"
  step "I am looking at a template"
  find("[type='submit']", match: :first).click
end

#Dann(/^ist das Startdatum heute und das Enddatum morgen$/) do
Then(/^the start date is today and the end date is tomorrow$/) do
  expect(find("#start_date").value).to eq I18n.localize(Date.today)
  expect(find("#end_date").value).to eq I18n.localize(Date.tomorrow)
end

#Dann(/^ich kann das Start\- und Enddatum einer potenziellen Bestellung ändern$/) do
Then(/^I can change the start and end date of a potential order$/) do
  @start_date = Date.tomorrow
  @end_date = Date.tomorrow + 4.days
  find("#start_date").set I18n.localize @start_date
  find("#end_date").set I18n.localize @end_date
end

#Dann(/^ich muss im Prozess weiterfahren zur Verfügbarkeitsanzeige der Vorlage$/) do
Then(/^I have to follow the process to the availability display of the template$/) do
  find("[type='submit']", match: :first).click
  expect(current_path).to eq borrow_template_availability_path(@template)
end
