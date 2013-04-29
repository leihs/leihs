# encoding: utf-8

Dann /^man sieht das Register Kategorien$/ do
  find("#navigation a[href*='categories']").should have_content _("Categories")
end

Wenn /^man das Register Kategorien wählt$/ do
  find("#navigation a[href*='categories']").click
end

Und /^man eine neue Kategorie erstellt$/ do
  find("a", text: _("Create %s") % _("Category")).click
end

Und /^man gibt man den Namen der Kategorie ein$/ do
  @new_category_name = "Neue Kategorie"
  find(".field.text input").set @new_category_name
end

Und /^man gibt die Elternelemente und die dazugehörigen Bezeichnungen ein$/ do
  @parent_category = ModelGroup.where(name: "Portabel").first
  checkbox = find("input[type='checkbox'][value='#{@parent_category.id}']")
  checkbox.set true
  @label_1 = "Label 1"
  find("li", text: "#{@parent_category.name}").find("input[type='text']").set @label_1
end

Dann /^ist die Kategorie mit dem angegegebenen Namen erstellt$/ do
  wait_until {current_path == (backend_inventory_pool_categories_path @current_inventory_pool)}
  ModelGroup.where(name: "#{@new_category_name}").count.should eql 1
end

Dann /^ist die Kategorie mit dem angegegebenen Namen und den zugewiesenen Elternelementen erstellt$/ do
  wait_until {current_path == (backend_inventory_pool_categories_path @current_inventory_pool)}
  ModelGroup.where(name: "#{@new_category_name}").count.should eql 1
  ModelGroupLink.where("ancestor_id = ? AND label = ?", @parent_category.id, @label_1).count.should eql 1
end

Dann /^sieht man die Liste der Kategorien$/ do
  wait_until {current_path == (backend_inventory_pool_categories_path @current_inventory_pool)}
  @parent_categories = ModelGroup.where(type: "Category").select { |mg| ModelGroupLink.where(descendant_id: mg.id).empty? }
  @parent_categories.each do |pc|
    find ".line.category", visible: true, text: pc.name
  end
end

Wenn /^man eine Kategorie editiert$/ do
  visit backend_inventory_pool_categories_path @current_inventory_pool
  @category= ModelGroup.where(name: "Portabel").first
  wait_until {find ".line.category"}
  all(".toggle .text").each {|toggle| toggle.click}
  find("a[href*='#{@category.id.to_s + '/edit'}']").click
end

Wenn /^man den Namen und die Elternelemente anpasst$/ do
  @new_category_name = "Neue Kategorie"
  find(".field.text input").set @new_category_name

  wait_until {find "input[type='checkbox']"}
  all("input[type='checkbox'][checked='checked']").map(&:value).uniq.each {|id| find("input[value='#{id}']").click}

  @new_parent_category_1 = ModelGroup.where(name: "Standard").first
  @new_parent_category_2 = ModelGroup.where(name: "Kurzdistanz").first
  @new_parent_category_3 = ModelGroup.where(name: "Stative").first
  @label_parent_category_1 = "Label Standard"
  @label_parent_category_2 = "Label Kurzdistanz"

  new_parent_checkbox_1 = find("input[type='checkbox'][value='#{@new_parent_category_1.id}']")
  new_parent_checkbox_1.click
  new_parent_checkbox_2 = find("input[type='checkbox'][value='#{@new_parent_category_2.id}']")
  new_parent_checkbox_2.click
  new_parent_checkbox_3 = find("input[type='checkbox'][value='#{@new_parent_category_3.id}']")
  new_parent_checkbox_3.click
  find("label", text: "#{@new_parent_category_1.name}").find(:xpath, "./../ul/li/input").set @label_parent_category_1
  find("label", text: "#{@new_parent_category_2.name}").find(:xpath, "./../ul/li/input").set @label_parent_category_2
end

Wenn /^man speichert die neue Kategorie/ do
  find("button", text: _("Create %s") % _("Category")).click
end

Wenn /^man speichert die editierte Kategorie/ do
  find("button", text: _("Save %s") % _("Category")).click
end

Dann /^werden die Werte gespeichert$/ do
  wait_until {current_path == (backend_inventory_pool_categories_path @current_inventory_pool)}
  @category.reload
  @category.name.should eql @new_category_name
  @category.links_as_child.count.should eql 3
  @category.links_as_child.map(&:label).to_set.delete_if(&:empty?).should eql [@label_parent_category_1, @label_parent_category_2].to_set
end

Und /^die Kategorien sind alphabetisch sortiert$/ do
  sorted_parent_categories = @parent_categories.sort
  @first_category = sorted_parent_categories.first
  @last_category = sorted_parent_categories.last
  @visible_categories = all(".line.category", visible: true)
  @visible_categories.first.text.include? @first_category.name
  @visible_categories.last.text.include? @last_category.name
end

Und /^die erste Ebene steht zuoberst$/ do
  @visible_categories.count.should eq @parent_categories.count
end

Und /^man kann die Unterkategorien anzeigen und verstecken$/ do
  child_name = @first_category.children.first.name
  expand_icon = @visible_categories.first.find(".icon")
  expand_icon.click
  page.should have_css(".line.category", visible: true, text: child_name)
  expand_icon.click
  page.should_not have_css(".line.category", visible: true, text: child_name)
end

Wenn /^man das Modell editiert$/ do
  @model = Model.where(name: "Sharp Beamer").first
  step 'ich nach "%s" suche' % @model.name
  wait_until { find(".line", :text => "#{@model.name}").find(".button", :text => _("Edit %s" % "Model")) }.click
end

Wenn /^ich die Kategorien zuteile$/ do
  @category_id = ModelGroup.where(name: "Standard").first.id
  find("input[value='#{@category_id}']").click
  # proof that checking checkbox at one place makes it selected everywhere in the tree
  all("input[value='#{@category_id}']").all? {|checkbox| checkbox.checked?}.should be_true
end

Wenn /^ich das Modell speichere$/ do
  find("button", text: _("Save %s") % _("Model")).click
end

Dann /^sind die Kategorien zugeteilt$/ do
  wait_until {all(".loading", :visible => true).size == 0}
  @model.model_groups.where(id: @category_id).count.should eq 1
end

Wenn /^ich eine oder mehrere Kategorien entferne$/ do
  @category_id_1 = ModelGroup.where(name: "Beamer").first.id
  @category_id_2 = ModelGroup.where(name: "Portabel").first.id

  find("input[value='#{@category_id_1}']").click
  # proof that checking checkbox at one place makes it selected everywhere in the tree
  all("input[value='#{@category_id_1}']").all? {|checkbox| checkbox.checked?}.should be_false

  find("input[value='#{@category_id_2}']").click
  # proof that checking checkbox at one place makes it selected everywhere in the tree
  all("input[value='#{@category_id_2}']").all? {|checkbox| checkbox.checked?}.should be_false
end

Dann /^sind die Kategorien entfernt und das Modell gespeichert$/ do
  wait_until {all(".loading", :visible => true).size == 0}
  @model.model_groups.should be_empty
end

Wenn /^eine Kategorie nicht genutzt ist$/ do
  @unused_category = Category.all.detect{|c| c.children.empty? and c.models.empty?}
end

Wenn /^man die Kategorie löscht$/ do
  visit backend_inventory_pool_categories_path @current_inventory_pool
  wait_until { find(".line.category[data-id='#{@unused_category.id}']") }
  all(".toggle .text").each do |toggle| toggle.click end
  find(".line.category[data-id='#{@unused_category.id}'] .actions .trigger").click
  find(".line.category[data-id='#{@unused_category.id}'] .actions .button", :text => _("Delete %s") % _("Category")).click
end

Dann /^ist die Kategorie gelöscht und alle Duplikate sind aus dem Baum entfernt$/ do
  wait_until {page.evaluate_script("jQuery.active") == 0}
  sleep(1)
  all(".line.category[data-id='#{@unused_category.id}']").empty?.should be_true
  lambda{@unused_category.reload}.should raise_error
end

Dann /^man bleibt in der Liste der Kategorien$/ do
  current_path.should == backend_inventory_pool_categories_path(@current_inventory_pool)
end

Wenn /^eine Kategorie genutzt ist$/ do
  @used_category = Category.all.detect{|c| not c.children.empty? or not c.models.empty?}
end

Dann /^ist es nicht möglich die Kategorie zu löschen$/ do
  visit backend_inventory_pool_categories_path @current_inventory_pool
  wait_until { find(".line.category[data-id='#{@used_category.id}']") }
  all(".line.category[data-id='#{@used_category.id}'] .actions .button", :text => _("Delete Category")).size.should == 0
end

Wenn /^ich eine ungenutzte Kategorie lösche die im Baum mehrmals vorhanden ist$/ do
  @unused_category = Category.all.detect{|x| x.models.count == 0 and x.children.count == 0 and x.parents.count > 1}
  step 'man die Kategorie löscht'
end

Wenn /^man nach einer Kategorie anhand des Namens sucht$/ do
  visit backend_inventory_pool_categories_path @current_inventory_pool
  @searchTerm ||= Category.first.name[0]
  countBefore = all(".line").size
  find("input[name='query']").set @searchTerm
  wait_until {countBefore != all(".line").size}
  sleep(1)
end

Dann /^sieht man nur die Kategorien, die den Suchbegriff im Namen enthalten$/ do
  all(".line.category", :visible => true).each do |line|
    expect(line.text).to match(Regexp.new(@searchTerm, "i"))
  end
end

Dann /^sieht die Ergebnisse in alphabetischer Reihenfolge$/ do
  names = all(".category_name", :visible => true).map{|name| name.text}
  expect(names.sort == names).to be_true
end

Dann /^man kann diese Kategorien editieren$/ do
  all(".line.category", :visible => true).each do |line|
    line.find("a[href*='categories'][href*='edit']")
  end
end

Wenn /^man nach einer ungenutzten Kategorie anhand des Namens sucht$/ do
  @unused_category = Category.all.detect{|c| c.children.empty? and c.models.empty?}
  @searchTerm = @unused_category.name
  step 'man nach einer Kategorie anhand des Namens sucht'
end

Dann /^man kann diese Kategorien löschen$/ do
  find(".line[data-id='#{@unused_category.id}']").find("[ng-click='delete_category(this)']")
end
