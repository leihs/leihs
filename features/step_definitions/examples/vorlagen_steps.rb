# -*- encoding : utf-8 -*-

Wenn(/^ich im Inventarbereich auf den Link "Vorlagen" klicke$/) do
  visit backend_inventory_pool_inventory_path(@current_inventory_pool)
  click_link _("Vorlagen")
end

Dann(/^öffnet sich die Seite mit der Liste der im aktuellen Inventarpool erfassten Vorlagen$/) do
  page.should have_content _("List of templates")
  @current_inventory_pool.templates.each do |t|
    page.should have_content t.name
  end
end

Dann(/^die Vorlagen für dieses Inventarpool sind alphabetisch nach Namen sortiert$/) do
  all_names = all(".line .modelname").map(&:text)
  all_names.sort.should == @current_inventory_pool.templates.sort.map(&:name)
  all_names.count.should == @current_inventory_pool.templates.count
end

Angenommen(/^ich befinde mich auf der Liste der Vorlagen$/) do
  visit backend_inventory_pool_templates_path(@current_inventory_pool)
end

Wenn(/^ich auf den Button "Neue Vorlage" klicke$/) do
  click_link _("New Template")
end

Dann(/^öffnet sich die Seite zur Erstellung einer neuen Vorlage$/) do
  current_path.should == new_backend_inventory_pool_template_path(@current_inventory_pool)
end

Wenn(/^ich den Namen der Vorlage eingebe$/) do
  first(".field", text: _("Name")).first("input").set "test"
end

Wenn(/^ich Modelle hinzufüge$/) do
  @changed_model = @current_inventory_pool.models.find {|m| m.items.borrowable.size > 1}
  fill_in_autocomplete_field("#{_("Quantity")} / #{_("Models")}", @changed_model.name)
end

Dann(/^steht bei jedem Modell die höchst mögliche ausleihbare Anzahl der Gegenstände für dieses Modell$/) do
  first(".field-inline-entry .capacity").text.should match /\/\s#{@changed_model.items.borrowable.size}/
end

Dann(/^für jedes hinzugefügte Modell ist die Mindestanzahl (\d+)$/) do |n|
  first(".field-inline-entry .capacity input").value.should == n
end

Wenn(/^ich zu jedem Modell die Anzahl angebe$/) do
  @new_value = 2
  first(".field-inline-entry .capacity input").set @new_value
end

Wenn(/^ich speichere die Vorlage$/) do
  click_button _("Save %s") % _("Template")
end

Dann(/^die neue Vorlage wurde mit all den erfassten Informationen erfolgreich gespeichert$/) do
  @template = @current_inventory_pool.templates.find_by_name("test")
  @template.model_links.size.should == 1
  @template.model_links.first.model.should == @changed_model
  @template.model_links.first.quantity.should == @new_value
end

Dann(/^ich wurde auf die Liste der Vorlagen weitergeleitet$/) do
  current_path.should == backend_inventory_pool_templates_path(@current_inventory_pool)
  page.should have_content _("List of templates")
end

Dann(/^ich sehe die Erfolgsbestätigung$/) do
  page.should have_selector(".success")
end

Angenommen(/^es existiert eine Vorlage mit mindestens zwei Modellen$/) do
  @template = @current_inventory_pool.templates.find do |t|
    t.models.size >= 2 and t.models.any? {|m| m.borrowable_items.size >= 2}
  end
  @template.should_not be_nil
  @template_models_count_original = @template.models.count
end

Wenn(/^ich auf den Button "Vorlage bearbeiten" klicke$/) do
  first(".line", text: @template.name).click_link _("Edit %s") % _("Template")
end

Dann(/^öffnet sich die Seite zur Bearbeitung einer existierenden Vorlage$/) do
  current_path.should == edit_backend_inventory_pool_template_path(@current_inventory_pool, @template)
end

Wenn(/^ich den Namen ändere$/) do
  @new_name = "new name"
  first(".field", text: _("Name")).first("input").set @new_name
end

Wenn(/^ich ein zusätzliches Modell hinzufüge$/) do
  @additional_model = @current_inventory_pool.models.find do |m|
    m.items.borrowable.size > 1 and not @template.models.include? m
  end
  fill_in_autocomplete_field("#{_("Quantity")} / #{_("Models")}", @additional_model.name)
end

Wenn(/^ein Modell aus der Liste lösche$/) do
  @removed_model = Model.find_by_name all(".field-inline-entry > span").last.text
  first(".field-inline-entry", text: @removed_model.name).first(".remove").click
end

Wenn(/^die Anzahl bei einem der Modell ändere$/) do
  @changed_model = Model.find_by_name all(".field-inline-entry > span").first.text
  @new_value = first(".field-inline-entry", text: @changed_model.name).first("input").value.to_i + 1
  first(".field-inline-entry", text: @changed_model.name).first("input").set @new_value
end

Wenn(/^ich speichere die bearbeitete Vorlage$/) do
  step "ich speichere die Vorlage"
end

Dann(/^die bearbeitete Vorlage wurde mit all den erfassten Informationen erfolgreich gespeichert$/) do
  @template.reload
  @template.models.map(&:name).should_not include @removed_model.name if @removed_model
  @template.models.map(&:name).should include @additional_model.name if @additional_model
  @template.model_links.find_by_model_id(@changed_model.id).quantity.should == @new_value
  @template.models.count.should == @template_models_count_original if @template_models_count_original
end

Dann(/^kann ich beliebige Vorlage direkt aus der Liste löschen$/) do
  @template = @current_inventory_pool.templates.first
  page.execute_script("$('.trigger .arrow').trigger('mouseover');")
  first(".line", text: @template.name).first(".button", text: _("Delete %s") % _("Template")).click
end

Dann(/^es wird mir dabei vorher eine Warnung angezeigt$/) do
  page.should have_selector "form.summary"
  click_button _("Delete")
end

Dann(/^die Vorlage wurde aus der Liste gelöscht$/) do
  step "ensure there are no active requests"
  page.should_not have_content @template.name
end

Dann(/^es ist mindestens ein Modell dem Template hinzugefügt$/) do
  fill_in_autocomplete_field("#{_("Quantity")} / #{_("Models")}", @current_inventory_pool.models.first.name)
end

Dann(/^die Vorlage wurde erfolgreich aus der Datenbank gelöscht$/) do
  expect{@template.reload}.to raise_exception
end

Angenommen(/^ich befinde mich auf der Erstellungsansicht einer Vorlage$/) do
  visit new_backend_inventory_pool_template_path(@current_inventory_pool)
end

Wenn(/^der Name nicht ausgefüllt ist$/) do
  first(".field", text: _("Name")).first("input").set ""
  first(".field", text: _("Name")).first("input").value.should be_empty
end

Wenn(/^ich den Namen einer bereits existierenden Vorlage eingebe$/) do
  first(".field", text: _("Name")).first("input").set @current_inventory_pool.templates.first.name
end

Wenn(/^ich den Name ausgefüllt habe$/) do
  first(".field", text: _("Name")).first("input").set "test"
end

Wenn(/^kein Modell hinzugefügt habe$/) do
  all(".field-inline-entry").each {|e| e.first(".remove").click}
end

Angenommen(/^ich befinde mich auf der Editieransicht einer Vorlage$/) do
  visit edit_backend_inventory_pool_template_path(@current_inventory_pool, @current_inventory_pool.templates.first)
end

Angenommen(/^ich befinde mich der Seite zur Erstellung einer neuen Vorlage$/) do
  step 'ich befinde mich auf der Liste der Vorlagen'
  step 'ich auf den Button "Neue Vorlage" klicke'
  step 'öffnet sich die Seite zur Erstellung einer neuen Vorlage'
end

Angenommen(/^ich habe den Namen der Vorlage eingegeben$/) do
  step 'ich den Namen der Vorlage eingebe'
end

Wenn(/^ich bei einem Modell eine Anzahl eingebe, welche höher ist als die höchst mögliche ausleihbare Anzahl der Gegenstände für dieses Modell$/) do
  max = first(".field-inline-entry", text: @changed_model.name).first(".capacity").text.gsub(/\D/, "").to_i
  @new_value = max + 1
  first(".field-inline-entry", text: @changed_model.name).first(".capacity input[name='template[model_links_attributes][][quantity]']").set @new_value
end

Dann(/^die Vorlage ist in der Liste (nicht )?als unerfüllbar markiert$/) do |n|
  if n
    first(".line", text: @template.name)[:class].split.include?("error").should be_false
  else
    first(".line", text: @template.name)[:class].split.include?("error").should be_true
  end
end

Wenn(/^ich die gleiche Vorlage bearbeite$/) do
  first(".line", text: @template.name).click_link _("Edit %s") % _("Template")
end

Wenn(/^ich die korrekte Anzahl angebe$/) do
  max = first(".field-inline-entry", text: @changed_model.name).first(".capacity").text.gsub(/\D/, "").to_i
  @new_value = max
  first(".field-inline-entry", text: @changed_model.name).first(".capacity input[name='template[model_links_attributes][][quantity]']").set @new_value
end
