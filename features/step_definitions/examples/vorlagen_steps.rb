# -*- encoding : utf-8 -*-

Wenn(/^ich im Inventarbereich auf den Link "Vorlagen" klicke$/) do
  @current_inventory_pool = @current_user.managed_inventory_pools.select {|ip| ip.templates.exists? }.sample
  visit manage_inventory_path(@current_inventory_pool)
  click_link _("Vorlagen")
end

Dann(/^öffnet sich die Seite mit der Liste der im aktuellen Inventarpool erfassten Vorlagen$/) do
  expect(has_content?(_("List of templates"))).to be true
  @current_inventory_pool.templates.each do |t|
    expect(has_content?(t.name)).to be true
  end
end

Dann(/^die Vorlagen für dieses Inventarpool sind alphabetisch nach Namen sortiert$/) do
  find(".line .col3of4 strong", match: :first)
  all_names = all(".line .col3of4 strong").map(&:text)
  expect(all_names.sort).to eq @current_inventory_pool.templates.sort.map(&:name)
  expect(all_names.count).to eq @current_inventory_pool.templates.count
end

Angenommen(/^ich befinde mich auf der Liste der Vorlagen$/) do
  visit manage_templates_path(@current_inventory_pool)
end

Wenn(/^ich auf den Button "Neue Vorlage" klicke$/) do
  click_link _("New Template")
end

Dann(/^öffnet sich die Seite zur Erstellung einer neuen Vorlage$/) do
  expect(current_path).to eq manage_new_template_path(@current_inventory_pool)
end

Wenn(/^ich den Namen der Vorlage eingebe$/) do
  find(".row.emboss.padding-inset-s", match: :prefer_exact, text: _("Name")).find("input").set "test"
end

Wenn(/^ich Modelle hinzufüge$/) do
  @changed_model = @current_inventory_pool.models.find {|m| m.items.borrowable.size > 1}
  fill_in_autocomplete_field("#{_("Quantity")} / #{_("Models")}", @changed_model.name)
end

Dann(/^steht bei jedem Modell die höchst mögliche ausleihbare Anzahl der Gegenstände für dieses Modell$/) do
  all("#models .line").each do |line|
    expect(line.find("input[name='template[model_links_attributes][][quantity]']").text).to match /\/\s#{@changed_model.items.borrowable.size}/
  end
end

Dann(/^für jedes hinzugefügte Modell ist die Mindestanzahl (\d+)$/) do |n|
  all("#models .line").each do |line|
    expect(line.find("input[name='template[model_links_attributes][][quantity]']").value).to eq n
  end
end

Dann(/^für das hinzugefügte Modell ist die Mindestanzahl (\d+)$/) do |n|
  expect(find("#models .line", match: :first, text: @additional_model.name).find("input[name='template[model_links_attributes][][quantity]']").value).to eq n
end

Wenn(/^ich zu jedem Modell die Anzahl angebe$/) do
  @new_value ||= 1
  all("#models .line").each do |line|
    line.find("input[name='template[model_links_attributes][][quantity]']").set @new_value
  end
end

Dann(/^die neue Vorlage wurde mit all den erfassten Informationen erfolgreich gespeichert$/) do
  @template = @current_inventory_pool.templates.find_by_name("test")
  expect(@template.model_links.size).to eq 1
  expect(@template.model_links.first.model).to eq @changed_model
  expect(@template.model_links.first.quantity).to eq @new_value
end

Dann(/^ich wurde auf die Liste der Vorlagen weitergeleitet$/) do
  expect(current_path).to eq manage_templates_path(@current_inventory_pool)
  expect(has_content?(_("List of templates"))).to be true
end

Dann(/^ich sehe die Erfolgsbestätigung$/) do
  find("#flash .notice")
end

Angenommen(/^es existiert eine Vorlage mit mindestens zwei Modellen$/) do
  @template = @current_inventory_pool.templates.find do |t|
    t.models.size >= 2 and t.models.any? {|m| m.borrowable_items.size >= 2}
  end
  expect(@template).not_to be nil
  @template_models_count_original = @template.models.count
end

Wenn(/^ich auf den Button "Vorlage bearbeiten" klicke$/) do
  find(".line", text: @template.name).click_link _("Edit")
end

Dann(/^öffnet sich die Seite zur Bearbeitung einer existierenden Vorlage$/) do
  expect(current_path).to eq manage_edit_template_path(@current_inventory_pool, @template)
end

Wenn(/^ich den Namen ändere$/) do
  @new_name = "new name"
  find(".row.emboss.padding-inset-s", match: :prefer_exact, text: _("Name")).find("input").set @new_name
end

Wenn(/^ich ein zusätzliches Modell hinzufüge$/) do
  @additional_model = @current_inventory_pool.models.find do |m|
    m.items.borrowable.size > 1 and not @template.models.include? m
  end
  fill_in_autocomplete_field("#{_("Quantity")} / #{_("Models")}", @additional_model.name)
end

Wenn(/^ein Modell aus der Liste lösche$/) do
  within all("#models .line").to_a.sample do
    @changed_model = Model.find_by_name(find("[data-model-name]").text)
    find(".button[data-remove]").click
  end
end

Wenn(/^die Anzahl bei einem der Modell ändere$/) do
  within all("#models .line:not(.striked)").to_a.sample do
    @changed_model = Model.find_by_name(find("[data-model-name]").text)
    @new_value = find("input").value.to_i + 1
    find("input").set @new_value
  end
end

Dann(/^die bearbeitete Vorlage wurde mit all den erfassten Informationen erfolgreich gespeichert$/) do
  @template.reload
  @template.models.map(&:name).should_not include @removed_model.name if @removed_model
  @template.models.map(&:name).should include @additional_model.name if @additional_model
  expect(@template.model_links.find_by_model_id(@changed_model.id).quantity).to eq @new_value
  expect(@template.models.count).to eq @template_models_count_original if @template_models_count_original
end

Dann(/^kann ich beliebige Vorlage direkt aus der Liste löschen$/) do
  @template = @current_inventory_pool.templates.sample
  within(".line", text: @template.name) do
    find(".multibutton .dropdown-toggle").click
    find(".multibutton .red[data-method='delete']", :text => _("Delete")).click
  end
end

Dann(/^es ist mindestens ein Modell dem Template hinzugefügt$/) do
  fill_in_autocomplete_field("#{_("Quantity")} / #{_("Models")}", @current_inventory_pool.models.first.name)
end

Dann(/^die Vorlage wurde erfolgreich aus der Datenbank gelöscht$/) do
  expect{@template.reload}.to raise_exception
end

Angenommen(/^ich befinde mich auf der Erstellungsansicht einer Vorlage$/) do
  visit manage_new_template_path(@current_inventory_pool)
end

Wenn(/^der Name nicht ausgefüllt ist$/) do
  within(".row.emboss.padding-inset-s", match: :prefer_exact, text: _("Name")) do
    find("input").set ""
    expect(find("input").value.empty?).to be true
  end
end

Wenn(/^ich den Namen einer bereits existierenden Vorlage eingebe$/) do
  find(".row.emboss.padding-inset-s", match: :prefer_exact, text: _("Name")).find("input").set @current_inventory_pool.templates.first.name
end

Wenn(/^kein Modell hinzugefügt habe$/) do
  all("#models .line").each {|e| e.find(".button[data-remove]").click}
end

Angenommen(/^ich befinde mich auf der Editieransicht einer Vorlage$/) do
  visit manage_edit_template_path(@current_inventory_pool, @current_inventory_pool.templates.first)
end

Angenommen(/^ich befinde mich der Seite zur Erstellung einer neuen Vorlage$/) do
  step 'ich befinde mich auf der Liste der Vorlagen'
  step 'ich auf den Button "Neue Vorlage" klicke'
  step 'öffnet sich die Seite zur Erstellung einer neuen Vorlage'
end

Angenommen(/^ich habe den Namen der Vorlage eingegeben$/) do
  step 'ich den Namen der Vorlage eingebe'
end

Wenn(/^ich den Name ausgefüllt habe$/) do
  step 'ich den Namen der Vorlage eingebe'
end

Wenn(/^ich bei einem Modell eine Anzahl eingebe, welche höher ist als die höchst mögliche ausleihbare Anzahl der Gegenstände für dieses Modell$/) do
  l = find("#models .line", match: :prefer_exact, text: @changed_model.name)
  max = l.find("[data-quantities]:nth-child(2)").text.gsub(/\D/, "").to_i
  @new_value = max + 1
  l.find("input[name='template[model_links_attributes][][quantity]']").set @new_value
end

Dann(/^die Vorlage ist in der Liste (nicht )?als unerfüllbar markiert$/) do |n|
  within(".line", text: @template.name) do
    if n
      expect(has_no_selector?(".line-info.red")).to be true
    else
      expect(has_selector?(".line-info.red")).to be true
    end
  end
end

Wenn(/^ich die gleiche Vorlage bearbeite$/) do
  find(".line", text: @template.name).click_link _("Edit")
end

Wenn(/^ich die korrekte Anzahl angebe$/) do
  within("#models .line", match: :prefer_exact, text: @changed_model.name) do
    max = find("[data-quantities]:nth-child(2)").text.gsub(/\D/, "").to_i
    @new_value = max
    find("input[name='template[model_links_attributes][][quantity]']").set @new_value
  end
end

Dann(/^ich sehe eine Warnmeldung wegen nicht erfüllbaren Vorlagen$/) do
  find(".red", text: _("The highlighted entries are not accomplishable for the intended quantity."))
end
