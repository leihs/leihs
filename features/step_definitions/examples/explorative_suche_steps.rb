# -*- encoding : utf-8 -*-

Angenommen(/^ich die Navigation der Kategorien aufklappe$/) do
  find("#categories-toggle").click
  find("#categories #category-list")
end

Wenn(/^ich eine Kategorie anwähle$/) do
  c = find("#categories #category-list a[data-type='category-filter']", match: :first)
  c_id = c[:"data-id"]
  @category = Category.find c_id
  expect(c.text).to eq @category.name

  c.click

  find("#categories #category-current a[data-type='category-current'][data-id='#{c_id}']", text: @category.name)
end

Dann(/^sehe ich die darunterliegenden Kategorien$/) do
  @category.children.each do |child|
    find("#categories", match: :prefer_exact, :text => child.name)
  end
end

Dann(/^kann die darunterliegende Kategorie anwählen$/) do
  @child_category = Category.find find("a[data-type='category-filter']", match: :first)[:"data-id"]
  expect(@category.children).to include @child_category

  find("a[data-type='category-filter']", match: :first).click

  find("#category-current", :text => @child_category.name)
end

Dann(/^ich sehe die Hauptkategorie sowie die aktuell ausgewählte und die darunterliegenden Kategorien$/) do
  find("#category-root", :text => @category.name)
  find("#category-current", :text => @child_category.name)
end

Dann(/^das Inventar wurde nach dieser Kategorie gefiltert$/) do
  within("#inventory") do
    find(".line[data-type='model']", match: :first)
    all(".line[data-type='model']").each do |model_line|
      model = Model.find_by_name(model_line.find(".col2of5 strong").text)
      expect((model.categories.include?(@child_category) or @child_category.descendants.any? {|c| model.categories.include? c})).to be true
    end
  end
end

Dann(/^ich kann in einem Schritt auf die aktuelle Hauptkategorie zurücknavigieren$/) do
  find("#category-root a").click
  step 'sehe ich die darunterliegenden Kategorien'
end

Dann(/^ich kann in einem Schritt auf die Übersicht der Hauptkategorien zurücknavigieren$/) do
  step 'kann ich in die übergeordnete Kategorie navigieren'
  Category.roots.each do |child|
    find("#categories #category-list [data-type='category-filter']", match: :prefer_exact, :text => child.name)
  end
end

Wenn(/^ich die Navigation der Kategorien wieder zuklappe$/) do
  find("#categories-toggle").click
end

Dann(/^sehe ich nur noch die Liste des Inventars$/) do
  expect(has_no_selector?("#categories #category-list", visible: true)).to be true
end

Angenommen(/^die Navigation der Kategorien ist aufgeklappt$/) do
  step 'ich die Navigation der Kategorien aufklappe'
end

Wenn(/^ich nach dem Namen einer Kategorie suche$/) do
  @category = Category.first
  @search_term = @category.name[0..-2]
  find("#category-search").set @search_term
  find("#category-root", :text => @search_term)
  find(".line", match: :first)
end

Dann(/^werden alle Kategorien angezeigt, welche den Namen beinhalten$/) do
  within "#categories #category-list" do
    Category.all.map(&:name).reject{|name| not name[@search_term]}.each do |name|
      find("[data-type='category-filter']", match: :prefer_exact, text: name)
    end
    expect(all("[data-type='category-filter']").size).to eq all("[data-type='category-filter']", text: @search_term).size
  end
end

Dann(/^ich sehe ein Suchicon mit dem Namen des gerade gesuchten Begriffs sowie die aktuell ausgewählte und die darunterliegenden Kategorien$/) do
  find("#category-root .icon-search")
  find("#category-root", :text => @search_term)
  find("#category-current", :text => @child_category.name)
  @child_category.children.each do |child|
    find("#category-list", :text => child.name)
  end
end

Angenommen(/^ich befinde mich in der Unterkategorie der explorativen Suche$/) do
  step 'man öffnet die Liste des Inventars'
  step 'ich die Navigation der Kategorien aufklappe'
  step 'ich eine Kategorie anwähle'
end

Dann(/^kann ich in die übergeordnete Kategorie navigieren$/) do
  find("#category-current a").click
end

Dann(/^die Modelle wurden nach dieser Kategorie gefiltert$/) do
  step "das Inventar wurde nach dieser Kategorie gefiltert"
end

Angenommen(/^ich befinde mich in einer Bestellung$/) do
  step 'ich öffne eine Bestellung'
end

Dann(/^kann ich ein Modell anhand der explorativen Suche wählen$/) do
  find("button.addon[type='submit'] .icon-plus-sign-alt").click
  find(".modal.ui-shown .line", match: :first)
  find("[data-type='category-filter']", :match => :first).click
  find(".modal.ui-shown .line", match: :first)
  model = Model.find find(".modal.ui-shown .line", match: :first)["data-id"]
  find(".modal.ui-shown .line .button", match: :first).click
  find("#flash")
  if @contract
    expect(@contract.models.include? model).to be true
  else
    expect(@customer.contracts.map(&:models).flatten.include? model).to be true
  end
end

Dann(/^die explorative Suche zeigt nur Modelle aus meinem Park an$/) do
  find("button.addon[type='submit'] .icon-plus-sign-alt").click
  find(".modal.ui-shown .line", match: :first)
  all(".modal .line[data-id]").each do |line|
    model = Model.find line["data-id"]
    expect(@current_inventory_pool.models.include? model).to be true
  end
end

Dann(/^die nicht verfügbaren Modelle sind rot markiert$/) do
  all(".model.line .availability", :text => /0 \(\d+\) \/ \d+/).each do |cell|
    line = cell.find(:xpath, "./../..")
    expect(line[:class]).to match /error/
  end
end
