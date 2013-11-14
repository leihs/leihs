# encoding: utf-8

Angenommen /^man öffnet die Liste der Modelle$/ do
  @current_inventory_pool = @current_user.managed_inventory_pools.sample
  visit "/manage/#{@current_inventory_pool.id}/inventory"
end

Wenn(/^ich ein ergänzendes Modell mittel Autocomplete Feld hinzufüge$/) do
  @comp1 = Model.find_by_name "Sharp Beamer"
  @comp2 = Model.find_by_name "Kamera Stativ"
  fill_in_autocomplete_field _("Compatibles"), @comp1.name
  fill_in_autocomplete_field _("Compatibles"), @comp2.name
end

Dann(/^ist dem Modell das ergänzende Modell hinzugefügt worden$/) do
  find(".top", match: :prefer_exact, text: _("List of Models"))
  @model.compatibles.size.should be 2
  @model.compatibles.any? {|m| m.name == @comp1.name}.should be_true
  @model.compatibles.any? {|m| m.name == @comp2.name}.should be_true
end

Wenn(/^ich ein Modell öffne, das bereits ergänzende Modelle hat$/) do
  @model = Model.find_by_name "Walkera v120"
  step 'ich nach "%s" suche' % @model.name
  find(".line", match: :first, text: @model.name).find(".button", text: _("Edit Model")).click
end

Wenn(/^ich ein ergänzendes Modell entferne$/) do
  find(".inner", match: :first, text: _("Compatibles")).all("label", text: _("delete")).each {|comp| comp.click}
end

Dann(/^ist das Modell ohne das gelöschte ergänzende Modell gespeichert$/) do
  find(".top", match: :prefer_exact, text: _("List of Models"))
  @model.reload.compatibles.should be_empty
end

Wenn(/^ich ein bereits bestehendes ergänzende Modell mittel Autocomplete Feld hinzufüge$/) do
  @comp = @model.compatibles.first
  fill_in_autocomplete_field _("Compatibles"), @comp.name
end

Dann(/^wurde das redundante Modell nicht hizugefügt$/) do
  find(".row.emboss", match: :first, text: _("Compatibles")).all(".field-inline-entry", text: @comp.name).count.should == 1
end

Dann(/^wurde das redundante ergänzende Modell nicht gespeichert$/) do
  find(".top", match: :prefer_exact, text: _("List of Models"))
  comp_before = @model.compatibles
  comp_before.count.should == @model.reload.compatibles.count
end

Angenommen(/^es existiert ein Modell mit folgenden Eigenschaften$/) do |table|
  conditions = table.raw.flatten.map do |condition|
    case condition
      when "in keinem Vertrag aufgeführt", "keiner Bestellung zugewiesen"
        lambda {|m| m.contract_lines.empty?}
      when "keine Gegenstände zugefügt"
        lambda {|m| m.items.empty?}
      when "hat Gruppenkapazitäten zugeteilt"
        lambda {|m| Partition.find_by_model_id(m.id)}
      when "hat Eigenschaften"
        lambda {|m| not m.properties.empty?}
      when "hat Zubehör"
        lambda {|m| not m.accessories.empty?}
      when "hat Bilder"
        lambda {|m| not m.images.empty?}
      when "hat Anhänge"
        lambda {|m| not m.attachments.empty?}
      when "hat Kategoriezuweisungen"
        lambda {|m| not m.categories.empty?}
      when "hat sich ergänzende Modelle"
        lambda {|m| not m.compatibles.empty?}
      else
        false
    end
  end
  @model = Model.find {|m| conditions.map{|c| c.class == Proc ? c.call(m) : c}.all?}
end

Dann(/^das Modell ist gelöscht$/) do
  step "ensure there are no active requests"
  Model.find_by_id(@model.id).should be_nil
end

Und /^das Modell hat (.+) zugewiesen$/ do |assoc|
  @model = Model.find do |m|
    case assoc
      when "Vertrag", "Bestellung"
        not m.contract_lines.empty?
      when "Gegenstand"
        not m.items.empty?
    end
  end
end

Dann(/^kann ich das Modell aus der Liste nicht löschen$/) do
  sleep(0.88)
  visit "/manage/#{@current_inventory_pool.id}/inventory"
  fill_in 'list-search', with: @model.name
  find("li.modelname", match: :prefer_exact, text: @model.name)
  find(".trigger .arrow", match: :first).hover
  find(".line.toggler.model", match: :prefer_exact, text: @model.name).should_not have_content(_("Delete %s") % _("Model"))
end

Und /^ich sehe eine Dialog-Fehlermeldung$/ do
  find(".flash_message").text.should_not be_empty
end

Dann(/^es wurden auch alle Anhängsel gelöscht$/) do
  Partition.find_by_model_id(@model.id).should be_nil
  Property.where(model_id: @model.id).should be_empty
  Accessory.where(model_id: @model.id).should be_empty
  Image.where(model_id: @model.id).should be_empty
  Attachment.where(model_id: @model.id).should be_empty
  ModelLink.where(model_id: @model.id).should be_empty
  Model.all {|m| m.compatibles.include? Model.find_by_name("Windows Laptop")}.include?(@model).should be_false
end

Wenn(/^ich dieses Modell aus der Liste lösche$/) do
  visit "/manage/#{@current_inventory_pool.id}/inventory"
  fill_in 'list-search', with: @model.name
  find("#inventory .line .col2of5 strong", match: :prefer_exact, text: @model.name).text.should == @model.name
  find(".trigger .arrow", match: :first).hover
  find(".line.toggler.model", match: :prefer_exact, text: @model.name).first(".button", text: _("Delete %s") % _("Model")).click
end

Dann(/^das Modell wurde aus der Liste gelöscht$/) do
  page.should_not have_content @model.name
end

Angenommen(/^ich editieren ein bestehndes Modell mit bereits zugeteilten Kapazitäten$/) do
  @model = @current_inventory_pool.models.find{|m| m.partitions.count > 0}
  visit "/manage/%d/models/%d/edit" % [@current_inventory_pool.id, @model.id]
end

Wenn(/^ich bestehende Zuteilungen entfernen$/) do
  page.should have_selector(".field-inline-entry")
  all(".field-inline-entry.partition").each do |line|
    line.first(".clickable", :text => _("Remove")).click
  end
end

Wenn(/^neue Zuteilungen hinzufügen$/) do
  @groups = @current_inventory_pool.groups - @model.partitions.map(&:group)

  @groups.each do |group|
    fill_in_autocomplete_field _("Allocations"), group.name
  end
end

Dann(/^sind die geänderten Gruppenzuteilungen gespeichert$/) do
  find(".top", match: :prefer_exact, text: _("List of Models"))
  model_group_ids = @model.reload.partitions.map(&:group_id)
  model_group_ids.sort.should == @groups.map(&:id)
end

Dann /^ist das neue Modell erstellt und unter ungenutzen Modellen auffindbar$/ do
  find("[data-unused_models]").click
  step "die Informationen sind gespeichert"
end

Wenn(/^ich ein bestehendes, genutztes Modell bearbeite$/) do
  @page_to_return = current_path
  @model = @current_inventory_pool.items.sample.model
  visit manage_edit_model_path @current_inventory_pool, @model
end