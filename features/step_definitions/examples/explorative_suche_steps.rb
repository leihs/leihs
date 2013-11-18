# -*- encoding : utf-8 -*-

Angenommen(/^ich die Navigation der Kategorien aufklappe$/) do
  find("#categories-toggle").click
  find("#categories #category-list")
end

Wenn(/^ich eine Kategorie anwähle$/) do
  @category = Category.find find("a[data-type='category-filter']", match: :first)[:"data-id"]
  page.execute_script %Q{ $("a[data-type='category-filter']").trigger("click") }
  find("#category-current", :text => @category.name)
end

Dann(/^sehe ich die darunterliegenden Kategorien$/) do
  @category.children.each do |child|
    find("#categories", match: :prefer_exact, :text => child.name)
  end
end

Dann(/^kann die darunterliegende Kategorie anwählen$/) do
  @child_category = Category.find find("a[data-type='category-filter']", match: :first)[:"data-id"]
  @category.children.should include @child_category
  page.execute_script %Q{ $("a[data-type='category-filter']").trigger("click") }
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
      model = Model.find_by_name model_line.find(".col2of5 strong").text
      (model.categories.include?(@child_category) or @child_category.descendants.any? {|c| model.categories.include? c}).should be_true
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
  page.should_not have_selector("#categories #category-list", visible: true)
end

Angenommen(/^die Navigation der Kategorien ist aufgeklappt$/) do
  step 'ich die Navigation der Kategorien aufklappe'
end

Wenn(/^ich nach dem Namen einer Kategorie suche$/) do
  @category = Category.first
  @search_term = @category.name[0..2]
  find("#category-search").set @search_term
  find("#category-root", :text => @search_term)
  find(".line", match: :first)
end

Dann(/^werden alle Kategorien angezeigt, welche den Namen beinhalten$/) do
  Category.all.map(&:name).reject{|name| ! name[@search_term]}.each do |name|
    find("#categories #category-list [data-type='category-filter']", match: :prefer_exact, :text => name)
  end
  all("#categories #category-list [data-type='category-filter']").size.should == all("#categories #category-list [data-type='category-filter']", :text => @search_term).size
end

Dann(/^ich wähle eine Kategorie$/) do
  step 'ich eine Kategorie anwähle'
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

Angenommen(/^ich befinde mich in der Liste der Modelle$/) do
  step 'man öffnet die Liste der Modelle'
end

Dann(/^die Modelle wurden nach dieser Kategorie gefiltert$/) do
  step "das Inventar wurde nach dieser Kategorie gefiltert"
end

Angenommen(/^ich befinde mich in einer Bestellung$/) do
  step 'ich öffne eine Bestellung'
end

Dann(/^kann ich ein Modell anhand der explorativen Suche wählen$/) do
  page.should have_selector "#process_helper"
  find("#process_helper *[type='submit']").click
  page.should have_selector(".modal .line")
  find("#category-list", :match => :first).click
  model = Model.find find(".modal .line", :match => :first)["data-id"]
  find(".line button.select-model", :match => :first).click
  page.should have_selector(".notification")
  if @contract
    expect(@contract.models.include? model).to be_true
  else
    expect(@customer.contracts.map(&:models).flatten.include? model).to be_true
  end
end

Dann(/^die explorative Suche zeigt nur Modelle aus meinem Park an$/) do
  find("#process_helper *[type='submit']").click
  page.should have_selector(".modal .line")
  all(".modal .model.line").each do |line|
    model = Model.find line["data-id"]
    expect(@current_inventory_pool.models.include? model).to be_true
  end
end

Dann(/^die nicht verfügbaren Modelle sind rot markiert$/) do
  all(".model.line .availability", :text => /0 \(\d+\) \/ \d+/).each do |cell|
    line = cell.find(:xpath, "./../..")
    (line[:class] =~ /error/).should_not be_nil
  end
end
