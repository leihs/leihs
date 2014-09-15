# encoding: utf-8

Wenn(/^ich ein ergänzendes Modell mittel Autocomplete Feld hinzufüge$/) do
  @comp1 = Model.find_by_name("Sharp Beamer 123")
  @comp2 = Model.find_by_name("Kamera Stativ 123")
  fill_in_autocomplete_field _("Compatibles"), @comp1.name
  fill_in_autocomplete_field _("Compatibles"), @comp2.name
end

Dann(/^ist dem Modell das ergänzende Modell hinzugefügt worden$/) do
  find("#flash")
  expect(@model.compatibles.size).to be 2
  expect(@model.compatibles.any? {|m| m.name == @comp1.name}).to be true
  expect(@model.compatibles.any? {|m| m.name == @comp2.name}).to be true
end

Wenn(/^ich ein Modell öffne, das bereits ergänzende Modelle hat$/) do
  @model = @current_inventory_pool.models.select {|m| m.compatibles.exists? }.sample

  @model ||= begin
    @current_inventory_pool = @current_user.managed_inventory_pools.select {|ip| not ip.models.empty? and ip.models.any? {|m| m.compatibles.exists?} }.sample
    visit manage_inventory_path(@current_inventory_pool)
    @current_inventory_pool.models.select {|m| m.compatibles.exists? }.sample
  end

  step 'ich nach "%s" suche' % @model.name
  find(".line", match: :first, text: @model.name).find(".button", text: _("Edit Model")).click
end

Wenn(/^ich ein ergänzendes Modell entferne$/) do
  find(".field", match: :first, text: _("Compatibles")).all("[data-remove]").each {|comp| comp.click}
end

Dann(/^ist das Modell ohne das gelöschte ergänzende Modell gespeichert$/) do
  find("#flash")
  expect(@model.reload.compatibles.empty?).to be true
end

Wenn(/^ich ein bereits bestehendes ergänzende Modell mittel Autocomplete Feld hinzufüge$/) do
  @comp = @model.compatibles.first
  fill_in_autocomplete_field _("Compatibles"), @comp.name
end

Dann(/^wurde das redundante Modell nicht hizugefügt$/) do
  expect(find(".row.emboss", match: :first, text: _("Compatibles")).all("[data-type='inline-entry']", text: @comp.name).count).to eq 1
end

Dann(/^wurde das redundante ergänzende Modell nicht gespeichert$/) do
  find("#flash")
  comp_before = @model.compatibles
  expect(comp_before.count).to eq @model.reload.compatibles.count
end

Angenommen(/^es existiert eine? (.+) mit folgenden Konditionen:$/) do |entity, table|
  conditions = table.raw.flatten.map do |condition|
    case condition
      when "in keinem Vertrag aufgeführt", "keiner Bestellung zugewiesen"
        lambda {|m| m.contract_lines.empty?}
      when "keine Gegenstände zugefügt"
        lambda {|m| m.items.items.empty?}
      when "keine Lizenzen zugefügt"
        lambda {|m| m.items.licenses.empty?}
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
  klass = case _(entity)
          when "Modell" then Model
          when "Software" then Software
          end
  @model = klass.find {|m| conditions.map{|c| c.class == Proc ? c.call(m) : c}.all?}
  expect(@model).not_to be nil
end

Und /^das Modell hat (.+) zugewiesen$/ do |assoc|
  @model = @current_inventory_pool.models.find do |m|
    case assoc
      when "Vertrag", "Bestellung"
        not m.contract_lines.empty?
      when "Gegenstand"
        not m.items.empty?
    end
  end
end

Dann(/^kann ich das Modell aus der Liste nicht löschen$/) do
  fill_in 'list-search', with: @model.name
  within(".line[data-id='#{@model.id}']") do
    find(".dropdown-holder").click
    expect(has_no_selector?("[data-method='delete']")).to be true
  end
  @model.reload # is still there
end

Und /^ich sehe eine Dialog-Fehlermeldung$/ do
  expect(find(".flash_message").text.empty?).to be false
end

Dann(/^es wurden auch alle Anhängsel gelöscht$/) do
  expect(Partition.find_by_model_id(@model.id)).to eq nil
  expect(Property.where(model_id: @model.id).empty?).to be true
  expect(Accessory.where(model_id: @model.id).empty?).to be true
  expect(Image.where(target_id: @model.id).empty?).to be true
  expect(Attachment.where(model_id: @model.id).empty?).to be true
  expect(ModelLink.where(model_id: @model.id).empty?).to be true
  expect(Model.all {|n| n.compatibles.include? Model.find_by_name("Windows Laptop")}.include?(@model)).to be false
  sleep(0.33) # fix lazy request problem
end

Dann(/^(?:die|das) (?:.+) wurde aus der Liste gelöscht$/) do
  [@model, @group, @template].compact.each {|entity|
    expect(has_no_content?(entity.name)).to be true
  }
end

Angenommen(/^ich editieren ein bestehndes Modell mit bereits zugeteilten Kapazitäten$/) do
  @model = @current_inventory_pool.models.find{|m| m.partitions.count > 0}
  visit manage_edit_model_path(@current_inventory_pool, @model)
end

Wenn(/^ich bestehende Zuteilungen entfernen$/) do
  find(".field", match: :first, text: _("Allocations")).all("[data-remove]").each {|comp| comp.click}
end

Wenn(/^neue Zuteilungen hinzufügen$/) do
  @groups = @current_inventory_pool.groups - @model.partitions.map(&:group)

  @groups.each do |group|
    fill_in_autocomplete_field _("Allocations"), group.name
  end
end

Dann(/^sind die geänderten Gruppenzuteilungen gespeichert$/) do
  find("#flash")
  model_group_ids = @model.reload.partitions.map(&:group_id)
  expect(model_group_ids.sort).to eq @groups.map(&:id)
end

Dann /^ist das neue Modell erstellt und unter ungenutzen Modellen auffindbar$/ do
  find(:select, "retired").first("option").select_option
  select _("not used"), from: "used"
  step "die Informationen sind gespeichert"
end

Wenn(/^ich ein bestehendes, genutztes Modell bearbeite$/) do
  @page_to_return = current_path
  @model = @current_inventory_pool.items.where(parent_id: nil).sample.model
  visit manage_edit_model_path @current_inventory_pool, @model
end

Wenn(/^I delete this (.+) from the list$/) do |entity|
  visit manage_inventory_path(@current_inventory_pool)

  case _(entity)
  when "Modell"
    find("[data-type='item']").click
  when "Software"
    find("[data-type='license']").click
    find(:select, "retired").first("option").select_option
  end

  fill_in 'list-search', with: @model.name
  find(".line[data-id='#{@model.id}'] .dropdown-holder").click
  find(".line[data-id='#{@model.id}'] [data-method='delete']").click
end

Dann(/^the "(.+)" is deleted$/) do |entity|
  find("#flash")
  klass = case _(entity)
          when "Modell" then Model
          when "Software" then Software
          end
  expect(klass.find_by_id(@model.id)).to eq nil
end

