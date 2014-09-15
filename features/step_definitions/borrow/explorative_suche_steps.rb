# -*- encoding : utf-8 -*-

Dann(/^sehe ich die explorative Suche$/) do
  find "#explorative-search"
end

Dann(/^sie beinhaltet die direkten Kinder und deren Kinder gemäss aktuell ausgewählter Kategorie$/) do
  @children = @category.children.reject {|c| Model.from_category_and_all_its_descendants(@category).active.blank?}
  @grand_children = @children.map(&:children).flatten.reject {|c| Model.from_category_and_all_its_descendants(c).active.blank?}

  within "#explorative-search" do
    @children.map(&:name).each {|c_name| find("a", match: :first, text: c_name)} unless @children.blank?
    @grand_children.map(&:name).each {|c_name| find("a", match: :first, text: c_name)} unless @grand_children.blank?
  end
end

Dann(/^diejenigen Kategorien, die oder deren Nachfolger keine ausleihbare Gegenstände beinhalten, werden nicht angezeigt$/) do
  expect((@children + @grand_children).length).to eq find("#explorative-search", match: :first).all("a").length
end

Wenn(/^ich eine Kategorie wähle$/) do
  @category = @category.children.reject {|c| Model.from_category_and_all_its_descendants(@category).active.blank?}.first
  find("#explorative-search", match: :first).find("a", match: :first, text: @category.name).click
end

Dann(/^werden die Modelle der aktuell angewählten Kategorie angezeigt$/) do
  expect((Rack::Utils.parse_nested_query URI.parse(current_url).query)["category_id"].to_i).to eq @category.id
  find("#model-list", match: :first)
  models = Model.from_category_and_all_its_descendants(@category.id).active
  within "#model-list" do
    models.each do |model|
      find(".line", match: :first, text: model.name)
    end
  end
end

Angenommen(/^man befindet sich auf der Modellliste einer Kategorie ohne Kinder$/) do
  @category = Category.find {|c| c.descendants.blank?}
  visit borrow_models_path category_id: @category.id
end

Dann(/^ist die explorative Suche nicht sichtbar und die Modellliste ist erweitert$/) do
  expect(has_selector?(".col1of1 #model-list")).to be true
end
