# encoding: utf-8

Dann /^man sieht das Register Kategorien$/ do
  find("nav a[href*='categories']", text: _("Categories"))
end

Wenn /^man das Register Kategorien wählt$/ do
  find("nav a[href*='categories']").click
  find("#categories-index-view h1", text: _("List of Categories"))
end

Und /^man eine neue Kategorie erstellt$/ do
  find("a", text: _("New Category")).click
end

Und /^man gibt man den Namen der Kategorie ein$/ do
  @new_category_name = "Neue Kategorie"
  find("input[name='category[name]']").set @new_category_name
end

Und /^man gibt die Elternelemente und die dazugehörigen Bezeichnungen ein$/ do
  @parent_category = ModelGroup.where(name: "Portabel").first
  checkbox = find("input[type='checkbox'][value='#{@parent_category.id}']")
  checkbox.set true
  @label_1 = "Label 1"
  find("li", text: "#{@parent_category.name}").find("input[type='text']").set @label_1
end

Dann /^ist die Kategorie mit dem angegegebenen Namen erstellt$/ do
  find("#categories-index-view h1", text: _("List of Categories"))
  current_path.should == manage_categories_path(@current_inventory_pool)
  ModelGroup.where(name: "#{@new_category_name}").count.should eql 1
end

Dann /^ist die Kategorie mit dem angegegebenen Namen und den zugewiesenen Elternelementen erstellt$/ do
  find("#categories-index-view h1", text: _("List of Categories"))
  current_path.should == manage_categories_path(@current_inventory_pool)
  ModelGroup.where(name: "#{@new_category_name}").count.should eql 1
  ModelGroupLink.where("ancestor_id = ? AND label = ?", @parent_category.id, @label_1).count.should eql 1
end

Dann /^sieht man die Liste der Kategorien$/ do
  within("#categories-index-view") do
    find("h1", text: _("List of Categories"))
    current_path.should == manage_categories_path(@current_inventory_pool)
    @parent_categories = ModelGroup.where(type: "Category").select { |mg| ModelGroupLink.where(descendant_id: mg.id).empty? }
    @parent_categories.each do |pc|
      find ".line", visible: true, text: pc.name
    end
  end
end

Wenn /^man eine Kategorie editiert$/ do
  visit manage_categories_path @current_inventory_pool
  @category = ModelGroup.where(name: "Portabel").first
  within("#categories-index-view #list") do
    find(".line", match: :first)
    all(".button[data-type='expander'] i.arrow.right").each {|toggle| toggle.click }
    find("a[href='/manage/%d/categories/%d/edit']" % [@current_inventory_pool.id, @category.id], match: :first).click
  end
end

Wenn /^man den Namen und die Elternelemente anpasst$/ do
  @new_category_name = "Neue Kategorie"
  find("input[name='category[name]']").set @new_category_name

  find("input[type='checkbox']", match: :first)
  all("input[type='checkbox'][checked='checked']").map(&:value).uniq.each {|id| find("input[value='#{id}']").click}

  @new_parent_category_1 = ModelGroup.where(name: "Standard").first
  @new_parent_category_2 = ModelGroup.where(name: "Kurzdistanz").first
  @new_parent_category_3 = ModelGroup.where(name: "Stative").first
  @label_parent_category_1 = "Label Standard"
  @label_parent_category_2 = "Label Kurzdistanz"

  new_parent_checkbox_1 = find("input[type='checkbox'][value='#{@new_parent_category_1.id}']", match: :first)
  new_parent_checkbox_1.click
  new_parent_checkbox_2 = find("input[type='checkbox'][value='#{@new_parent_category_2.id}']", match: :first)
  new_parent_checkbox_2.click
  new_parent_checkbox_3 = find("input[type='checkbox'][value='#{@new_parent_category_3.id}']", match: :first)
  new_parent_checkbox_3.click
  find("label", match: :prefer_exact, text: @new_parent_category_1.name).find(:xpath, "./../ul/li/input").set @label_parent_category_1
  find("label", match: :prefer_exact, text: @new_parent_category_2.name).find(:xpath, "./../ul/li/input").set @label_parent_category_2
end

Dann /^werden die Werte gespeichert$/ do
  find("#categories-index-view h1", text: _("List of Categories"))
  current_path.should == manage_categories_path(@current_inventory_pool)
  @category.reload
  @category.name.should eql @new_category_name
  @category.links_as_child.count.should eql 3
  @category.links_as_child.map(&:label).to_set.delete_if(&:empty?).should eql [@label_parent_category_1, @label_parent_category_2].to_set
end

Und /^die Kategorien sind alphabetisch sortiert$/ do
  sorted_parent_categories = @parent_categories.sort
  @first_category = sorted_parent_categories.first
  @last_category = sorted_parent_categories.last
  @visible_categories = all("#categories-index-view .line", visible: true)
  @visible_categories.first.text.include? @first_category.name
  @visible_categories.last.text.include? @last_category.name
end

Und /^die erste Ebene steht zuoberst$/ do
  @visible_categories.count.should eq @parent_categories.count
end

Und /^man kann die Unterkategorien anzeigen und verstecken$/ do
  child_name = @first_category.children.first.name
  within @visible_categories.first do
    find(".button[data-type='expander'] i.arrow.right").click
    find(".button[data-type='expander'] i.arrow.down")
  end
  find(".group-of-lines .line .col3of9:nth-child(2) strong", visible: true, text: child_name)
  within @visible_categories.first do
    find(".button[data-type='expander'] i.arrow.down").click
    find(".button[data-type='expander'] i.arrow.right")
  end
  page.has_selector?(".group-of-lines .line .col3of9:nth-child(2) strong", visible: true, text: child_name).should be_false
end

Wenn /^man das Modell editiert$/ do
  @model = Model.where(name: "Sharp Beamer").first
  step 'ich nach "%s" suche' % @model.name
  find(".line", :text => "#{@model.name}", match: :prefer_exact).find(".button", :text => _("Edit %s" % "Model")).click
end

Wenn /^ich die Kategorien zuteile$/ do
  @category = ModelGroup.where(name: "Standard").first
  find("#categories input[data-type='autocomplete']").set @category.name
  find("a.ui-corner-all", match: :first, text: @category.name).click
  find("#categories .list-of-lines .line", text: @category.name)
end

Wenn /^ich das Modell speichere$/ do
  click_button _("Save %s") % _("Model")
  find("h1", text: _("List of Inventory"))
end

Dann /^sind die Kategorien zugeteilt$/ do
  step "ensure there are no active requests"
  @model.model_groups.where(id: @category.id).count.should eq 1
end

Wenn /^ich eine oder mehrere Kategorien entferne$/ do
  within("#categories .list-of-lines") do
    @model.categories.each do |category|
      find(".line", text: category.name).find(".button[data-remove]", text: _("Remove")).click
    end
  end
end

Dann /^sind die Kategorien entfernt und das Modell gespeichert$/ do
  page.has_content? _("List of Models")
  @model.categories.reload.should be_empty
end

Wenn /^eine Kategorie nicht genutzt ist$/ do
  @unused_category = Category.all.detect{|c| c.children.empty? and c.models.empty?}
end

Wenn /^man die Kategorie löscht$/ do
  visit manage_categories_path @current_inventory_pool
  within("#categories-index-view #list") do
    find(".line", match: :first)
    all(".button[data-type='expander'] i.arrow.right").each {|toggle| toggle.click }
    within(".line[data-id='#{@unused_category.id}']", match: :first) do
      find(".multibutton .dropdown-holder .dropdown-toggle").hover
      find(".multibutton .dropdown-item.red[data-method='delete']", text: _("Delete")).click
    end
  end
end

Dann /^ist die Kategorie gelöscht und alle Duplikate sind aus dem Baum entfernt$/ do
  sleep(0.88)
  all("#categories-index-view .line[data-id='#{@unused_category.id}']").empty?.should be_true
  lambda{@unused_category.reload}.should raise_error
end

Dann /^man bleibt in der Liste der Kategorien$/ do
  find("#categories-index-view h1", text: _("List of Categories"))
  current_path.should == manage_categories_path(@current_inventory_pool)
end

Wenn /^eine Kategorie genutzt ist$/ do
  @used_category = Category.all.detect{|c| not c.children.empty? or not c.models.empty?}
end

Dann /^ist es nicht möglich die Kategorie zu löschen$/ do
  visit manage_categories_path @current_inventory_pool
  within("#categories-index-view #list") do
    within(".line[data-id='#{@used_category.id}']") do
      all(".multibutton .dropdown-holder .dropdown-toggle").size.should == 0
      all(".multibutton .dropdown-item.red[data-method='delete']", text: _("Delete")).size.should == 0
    end
  end
end

Wenn /^ich eine ungenutzte Kategorie lösche die im Baum mehrmals vorhanden ist$/ do
  @unused_category = Category.all.detect{|x| x.models.count == 0 and x.children.count == 0 and x.parents.count > 1}
  step 'man die Kategorie löscht'
end

Wenn /^man nach einer Kategorie anhand des Namens sucht$/ do
  visit manage_categories_path @current_inventory_pool
  @searchTerm ||= Category.first.name[0]
  countBefore = all(".line").size
  find("#list-search").set @searchTerm
  step "ensure there are no active requests"
  countBefore.should_not == all(".line").size
  sleep(0.88)
end

Dann /^sieht man nur die Kategorien, die den Suchbegriff im Namen enthalten$/ do
  all("#categories-index-view .line", :visible => true).each do |line|
    expect(line.text).to match(Regexp.new(@searchTerm, "i"))
  end
end

Dann /^sieht die Ergebnisse in alphabetischer Reihenfolge$/ do
  names = all(".category_name", :visible => true).map{|name| name.text}
  expect(names.sort == names).to be_true
end

Dann /^man kann diese Kategorien editieren$/ do
  all("#categories-index-view .line", :visible => true).each do |line|
    line.find("a[href*='categories'][href*='edit']")
  end
end

Wenn /^man nach einer ungenutzten Kategorie anhand des Namens sucht$/ do
  @unused_category = Category.all.detect{|c| c.children.empty? and c.models.empty?}
  @searchTerm = @unused_category.name
  step 'man nach einer Kategorie anhand des Namens sucht'
end

Dann /^man kann diese Kategorien löschen$/ do
  within(".line[data-id='#{@unused_category.id}']", match: :first) do
    find(".multibutton .dropdown-holder .dropdown-toggle").hover
    find(".multibutton .dropdown-item.red[data-method='delete']", text: _("Delete"))
  end
end
