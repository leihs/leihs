# -*- encoding : utf-8 -*-

Angenommen(/^ich befinde mich im Admin\-Bereich im Reiter Gruppen$/) do
  visit backend_inventory_pool_groups_path(@current_inventory_pool)
end

Dann(/^sehe ich die Liste der Gruppen$/) do
  @current_inventory_pool.groups.each do |group|
    find(".line .name", :text => group.name)
  end
end

Dann(/^die Anzahl zugeteilter Benutzer$/) do
  @current_inventory_pool.groups.each do |group|
    find(".line", :text => group.name).find(".quantity", :text => group.users.size.to_s)
  end
end

Dann(/^die Anzahl der zugeteilten Modell\-Kapazitäten$/) do
  @current_inventory_pool.groups.each do |group|
    find(".line", :text => group.name).find(".quantity", :text => group.models.size.to_s)
    find(".line", :text => group.name).find(".quantity", :text => group.partitions.sum(&:quantity).to_s)
  end
end

Dann(/^die Liste ist alphabetisch sortiert$/) do
  (all(".line .name").map(&:text).to_json == Group.all.map(&:name).sort.to_json).should be_true
end

Wenn(/^ich eine Gruppe erstelle$/) do
  find(".button", :text => _("Create %s") % _("Group")).click
end

Wenn(/^den Namen der Gruppe angebe$/) do
  @name = Faker::Name.name
  fill_in "group[name]", :with => @name
end

Wenn(/^die Benutzer hinzufüge$/) do
  @users = @current_inventory_pool.users.customers
  @users.each do |user|
   fill_in "add-user", :with => user.name
   wait_until{find(".ui-menu-item a", :text => user.name)}
   find(".ui-menu-item a", :text => user.name).click
  end
end

Wenn(/^die Modelle und deren Kapazität hinzufüge$/) do
  @models = @current_inventory_pool.models[0..2]
  @partitions = []
  @models.each do |model|
    fill_in "add-model", :with => model.name
    wait_until{find(".ui-menu-item a", :text => model.name)}
    find(".ui-menu-item a", :text => model.name).click
    partition = {:model_id => model.id, :quantity => rand(model.items.where(:inventory_pool_id => @current_inventory_pool.id).borrowable.size-1)+1}
    @partitions.push partition
    find(".field-inline-entry", :text => model.name).fill_in "group[partitions_attributes][][quantity]", :with => partition[:quantity]
  end
end

Wenn(/^ich speichere die Gruppe$/) do
  find(".button", :text => _("Save %s") % _("Group")).click
end

Dann(/^ist die Gruppe gespeichert$/) do
  @group = Group.find_by_name @name
end

Dann(/^die Benutzer und Modelle mit deren Kapazitäten sind zugeteilt$/) do
  @group.users.reload.map(&:id).sort.should == @users.map(&:id).sort
  @group.partitions.map{|p| {:model_id => p.model_id, :quantity => p.quantity}}.should == @partitions
end

Dann(/^ich sehe die Gruppenliste alphabetisch sortiert$/) do
  step 'sehe ich die Liste der Gruppen'
  step 'die Liste ist alphabetisch sortiert'
end

Dann(/^ich sehe eine Bestätigung$/) do
  find(".notification")
end

Wenn(/^ich eine bestehende Gruppe editiere$/) do
  @group = @current_inventory_pool.groups.first
  visit edit_backend_inventory_pool_group_path @group.inventory_pool_id, @group
end

Wenn(/^ich den Namen der Gruppe ändere$/) do
  @name = Faker::Name.name
  fill_in "group[name]", :with => @name
end

Wenn(/^die Benutzer hinzufüge und entferne$/) do
  all("[name*='users'][name*='id']").each do |existing_user_line|
    existing_user_line.find(:xpath, "./..").find(".clickable", :text => _("Remove")).click
  end
  user = (@current_inventory_pool.users-@group.users).shuffle.first
  @users = [user]
  fill_in "add-user", :with => user.name
  wait_until{find(".ui-menu-item a", :text => user.name)}
  find(".ui-menu-item a", :text => user.name).click
end

Wenn(/^die Modelle und deren Kapazität hinzufüge und entferne$/) do
  all("[name='group[partitions_attributes][][quantity]']").each do |existing_partition_line|
    existing_partition_line.find(:xpath, "./../..").find(".clickable", :text => _("Remove")).click
  end
  model = (@current_inventory_pool.models-@group.models).first
  fill_in "add-model", :with => model.name
  wait_until{find(".ui-menu-item a", :text => model.name)}
  find(".ui-menu-item a", :text => model.name).click
  partition = {:model_id => model.id, :quantity => rand(model.items.where(:inventory_pool_id => @current_inventory_pool.id).borrowable.size-1)+1}
  @partitions = [partition]
  find(".field-inline-entry", :text => model.name).fill_in "group[partitions_attributes][][quantity]", :with => partition[:quantity]
end

Dann(/^ich sehe die Gruppenliste$/) do
  step 'sehe ich die Liste der Gruppen'
end

Dann(/^sehe ich die noch nicht zugeteilten Kapazitäten$/) do
  @partitions.each do |partition|
    model = Model.find partition[:model_id]
    find(".field-inline-entry", :text => model.name).should have_content("/ #{model.items.scoped_by_inventory_pool_id(@current_inventory_pool.id).borrowable.size}")
  end
end

Wenn(/^ich eine Gruppe lösche$/) do
  @group = @current_inventory_pool.groups.detect &:can_destroy?
  visit backend_inventory_pool_groups_path @current_inventory_pool
  wait_until { find("ul.line", text: @group.name) }
  page.execute_script("$('.trigger .arrow').trigger('mouseover');")
  find("ul.line", text: @group.name).find(".button", text: _("Delete %s") % _("Group")).click
end

Wenn(/^die Gruppe wurde aus der Liste gelöscht$/) do
  page.has_no_selector? "ul.line", text: @group.name
end

Wenn(/^die Gruppe wurde aus der Datenbank gelöscht$/) do
  Group.find_by_name(@group.name).should be_nil
end
