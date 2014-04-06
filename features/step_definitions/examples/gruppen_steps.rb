# -*- encoding : utf-8 -*-

Angenommen(/^ich befinde mich im Admin\-Bereich im Reiter Gruppen$/) do
  visit manage_inventory_pool_groups_path(@current_inventory_pool)
end

Dann(/^sehe ich die Liste der Gruppen$/) do
  @current_inventory_pool.groups.reload.each do |group|
    find(".list-of-lines .line strong", :text => group.name)
  end
end

Dann(/^die Anzahl zugeteilter Benutzer$/) do
  @current_inventory_pool.groups.each do |group|
    find(".line", :text => group.name).first(".quantity", :text => group.users.size.to_s)
  end
end

Dann(/^die Anzahl der zugeteilten Modell\-Kapazitäten$/) do
  @current_inventory_pool.groups.each do |group|
    find(".line", :text => group.name).first(".quantity", :text => group.models.size.to_s)
    find(".line", :text => group.name).first(".quantity", :text => group.partitions.sum(&:quantity).to_s)
  end
end

Dann(/^die Liste ist alphabetisch sortiert$/) do
  (all(".list-of-lines .line strong").map(&:text).to_json == @current_inventory_pool.groups.map(&:name).sort.to_json).should be_true
end

Wenn(/^ich eine Gruppe erstelle$/) do
  find(".button", :text => _("New Group")).click
end

Wenn(/^den Namen der Gruppe angebe$/) do
  @name = Faker::Name.name
  fill_in "group[name]", :with => @name
end

Wenn(/^die Benutzer hinzufüge$/) do
  @users = @current_inventory_pool.users.customers
  @users.each do |user|
    find("input[data-search-users]").set user.name
    find(".ui-menu-item a", match: :prefer_exact, :text => user.name).click
  end
end

Wenn(/^die Modelle und deren Kapazität hinzufüge$/) do
  @models = @current_inventory_pool.models[0..2]
  @partitions = []
  @models.each do |model|
    find("input[data-search-models]").set model.name
    find(".ui-menu-item a", match: :prefer_exact, :text => model.name).click
    borrowable_items = model.items.where(:inventory_pool_id => @current_inventory_pool.id).borrowable.size - 1
    partition = {:model_id => model.id, :quantity => (borrowable_items.zero? ? 0 : rand(borrowable_items)) + 1}
    @partitions.push partition
    find(".list-of-lines .line", text: model.name).fill_in "group[partitions_attributes][][quantity]", :with => partition[:quantity]
  end
end

Dann(/^ist die Gruppe gespeichert$/) do
  @group = Group.find_by_name @name
  @group.should_not be_nil
end

Dann(/^die Benutzer und Modelle mit deren Kapazitäten sind zugeteilt$/) do
  @group.users.reload.map(&:id).sort.should == @users.map(&:id).sort
  Set.new(@group.partitions.map{|p| {:model_id => p.model_id, :quantity => p.quantity}}).should == Set.new(@partitions)
end

Dann(/^ich sehe die Gruppenliste alphabetisch sortiert$/) do
  step 'sehe ich die Liste der Gruppen'
  step 'die Liste ist alphabetisch sortiert'
end

Dann(/^ich sehe eine Bestätigung$/) do
  find("#flash .success")
end

Wenn(/^ich eine bestehende Gruppe editiere$/) do
  @group = @current_inventory_pool.groups.find {|g| g.models.length >= 2 and g.users.length >= 2}
  visit manage_edit_inventory_pool_group_path @group.inventory_pool_id, @group
end

Wenn(/^ich den Namen der Gruppe ändere$/) do
  @name = Faker::Name.name
  fill_in "group[name]", :with => @name
end

Wenn(/^die Benutzer hinzufüge und entferne$/) do
  all("[name*='users'][name*='id']", visible: false).each do |existing_user_line|
    existing_user_line.first(:xpath, "./..").find(".button[data-remove-user]", :text => _("Remove")).click
  end
  user = (@current_inventory_pool.users-@group.users).sample
  @users = [user]
  find("input[data-search-users]").set user.name
  find(".ui-menu-item a", match: :prefer_exact, :text => user.name).click
end

Wenn(/^die Modelle und deren Kapazität hinzufüge und entferne$/) do
  all("[name='group[partitions_attributes][][quantity]']").each do |existing_partition_line|
    existing_partition_line.first(:xpath, "./../../..").find(".button[data-remove-group]", :text => _("Remove")).click
  end
  model = (@current_inventory_pool.models-@group.models).first
  find("input[data-search-models]").set model.name
  find(".ui-menu-item a", match: :prefer_exact, :text => model.name).click
  partition = {:model_id => model.id, :quantity => rand(model.items.where(:inventory_pool_id => @current_inventory_pool.id).borrowable.size-1)+1}
  @partitions = [partition]
  find(".list-of-lines .line", :text => model.name).fill_in "group[partitions_attributes][][quantity]", :with => partition[:quantity]
end

Dann(/^ich sehe die Gruppenliste$/) do
  step 'sehe ich die Liste der Gruppen'
end

Dann(/^sehe ich die noch nicht zugeteilten Kapazitäten$/) do
  @partitions.each do |partition|
    model = Model.find partition[:model_id]
    find("input[value='#{model.id}']", visible: false).parent.should have_content("/ #{model.items.where(inventory_pool_id: @current_inventory_pool.id).borrowable.size}")
  end
end

Wenn(/^ich eine Gruppe lösche$/) do
  @group = @current_inventory_pool.groups.detect &:can_destroy?
  visit manage_inventory_pool_groups_path @current_inventory_pool
  within(".list-of-lines .line", text: @group.name) do
    find(".multibutton .dropdown-toggle").hover
    find(".multibutton .dropdown-item.red", text: _("Delete")).click
  end
end

Wenn(/^die Gruppe wurde aus der Liste gelöscht$/) do
  page.has_no_selector? "ul.line", text: @group.name
end

Wenn(/^die Gruppe wurde aus der Datenbank gelöscht$/) do
  Group.find_by_name(@group.name).should be_nil
end

Wenn(/^ich einen Benutzer hinzufüge$/) do
  fill_in_autocomplete_field _("Users"), @user_name = @current_inventory_pool.users.sample.name
end

Dann(/^wird der Benutzer zuoberst in der Liste hinzugefügt$/) do
  find("#users .list-of-lines .line [data-user-name]", text: @user_name)
end

Wenn(/^ich ein Modell hinzufüge$/) do
  fill_in_autocomplete_field _("Models"), @model_name = @current_inventory_pool.models.first.name
end

Dann(/^wird das Modell zuoberst in der Liste hinzugefügt$/) do
  page.has_selector? "#models-allocations .list-of-lines .line", text: @model_name
  find("#models-allocations .list-of-lines .line", match: :first).text.should match @model_name
end

Dann(/^sind die bereits hinzugefügten Benutzer alphabetisch sortiert$/) do
  within("#users") do
    all(".list-of-lines .line").size.should > 0
    entries = all(".list-of-lines .line")
    entries.map(&:text).sort.should == entries.map(&:text)
  end
end

Dann(/^sind die bereits hinzugefügten Modelle alphabetisch sortiert$/) do
  within("#models-allocations") do
    all(".list-of-lines .line").size.should > 0
    entries = all(".list-of-lines .line")
    entries.map(&:text).sort.should == entries.map(&:text)
  end
end

Wenn(/^ich ein bereits hinzugefügtes Modell hinzufüge$/) do
  @model = @group.models.first
  @quantity = 2
  find("#models-allocations .list-of-lines .line", match: :prefer_exact, text: @model_name).fill_in "group[partitions_attributes][][quantity]", :with => @quantity
  fill_in_autocomplete_field _("Models"), @model.name
end

Dann(/^wird das Modell nicht erneut hinzugefügt$/) do
  find ".row.emboss", match: :prefer_exact, text: _("Models")
  find("#models-allocations .list-of-lines .line", text: @model.name)
end

Wenn(/^ich einen bereits hinzugefügten Benutzer hinzufüge$/) do
  @user = @group.users.first
  fill_in_autocomplete_field _("Users"), @user.name
end

Dann(/^wird der Benutzer nicht hinzugefügt$/) do
  find("#users .list-of-lines .line", text: @user.name)
end

Dann(/^das vorhandene Modell ist nach oben gerutscht$/) do
  find("#models-allocations .list-of-lines .line", match: :first).text.should match @model.name
end

Dann(/^der vorhandene Benutzer ist nach oben gerutscht$/) do
  find("#users .list-of-lines .line", match: :first).text.should match @user.name
end

Dann(/^das vorhandene Modell behält die eingestellte Anzahl$/) do
  find("#models-allocations .list-of-lines .line", match: :prefer_exact, text: @model.name).find("input[name='group[partitions_attributes][][quantity]']").value.to_i.should == @quantity
end
