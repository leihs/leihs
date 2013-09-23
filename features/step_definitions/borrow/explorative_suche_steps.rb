# -*- encoding : utf-8 -*-

Dann(/^sehe ich die explorative Suche$/) do
  find "#explorative-search"
end

Dann(/^sie beinhaltet die direkten Kinder und deren Kinder gemäss aktuell ausgewählter Kategorie$/) do
  @children = @category.children.reject {|c| Model.from_category_and_all_its_descendants(@category).active.blank?}
  @grand_children = @children.map(&:children).flatten.reject {|c| Model.from_category_and_all_its_descendants(c).active.blank?}

  within "#explorative-search" do
    @children.map(&:name).each {|c_name| first("a", text: c_name)} unless @children.blank?
    @grand_children.map(&:name).each {|c_name| first("a", text: c_name)} unless @grand_children.blank?
  end
end

Dann(/^diejenigen Kategorien, die oder deren Nachfolger keine ausleihbare Gegenstände beinhalten, werden nicht angezeigt$/) do
  (@children + @grand_children).length.should eq first("#explorative-search").all("a").length
end

Wenn(/^ich eine Kategorie wähle$/) do
  @category = @category.children.reject {|c| Model.from_category_and_all_its_descendants(@category).active.blank?}.first
  first("#explorative-search").first("a", text: @category.name).click
end

Dann(/^werden die Modelle der aktuell angewählten Kategorie angezeigt$/) do
  (Rack::Utils.parse_nested_query URI.parse(current_url).query)["category_id"].to_i.should == @category.id
  first("#model-list")
  models = Model.from_category_and_all_its_descendants(@category.id).active
  within "#model-list" do
    models.each do |model|
      first(".line", text: model.name)
    end
  end
end

Angenommen(/^man befindet sich auf der Modellliste einer Kategorie ohne Kinder$/) do
  @category = Category.find {|c| c.descendants.blank?}
  visit borrow_models_path category_id: @category.id
end

Dann(/^ist die explorative Suche nicht sichtbar und die Modellliste ist erweitert$/) do
  page.should have_selector ".col1of1 #model-list"
end
