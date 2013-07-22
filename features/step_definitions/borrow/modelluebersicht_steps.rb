# -*- encoding : utf-8 -*-

Angenommen(/^man befindet sich auf der Liste der Modelle$/) do
  @model = @current_user.models.borrowable.detect do |m|
    m.images.size > 1 and
    not m.description.blank? and
    not m.attachments.blank? and
    m.properties.length > 5 and
    not m.compatibles.blank?
  end
  category = @model.categories.first
  visit borrow_models_path(category_id: category.id)
end

Wenn(/^ich ein Modell auswähle$/) do
  find(".line[data-id='#{@model.id}']").click
end

Dann(/^lande ich auf der Modellübersicht$/) do
  current_path.should == borrow_model_path(@model)
end

Dann(/^ich sehe die folgenden Informationen$/) do |table|
  table.raw.flatten.each do |section|
    case section
      when "Modellname" 
        page.should have_content @model.name
      when "Hersteller"
        page.should have_content @model.manufacturer
      when "Bilder"
        @model.images.each_with_index {|image,i| find("img[src='#{model_image_thumb_path(@model, :offset => i)}']")}
      when "Beschreibung"
        page.should have_content @model.description
      when "Anhänge"
        @model.attachments.each {|a| find("a[href='#{a.public_filename}']")}
      when "Eigenschaften"
        @model.properties.each do |p|
          page.should have_content p.key
          page.should have_content p.value
        end
      when "Ergänzende Modelle"
        @model.compatibles.each do |c|
          find("a[href='#{borrow_model_path(c)}']")
          find("img[src='#{model_image_thumb_path(c)}']")
          page.should have_content c.name
        end
      else
        rais "unkown section"
    end
  end
end

Angenommen(/^man befindet sich in einer Modellübersicht mit Bildern$/) do
  @model = @current_user.models.borrowable.detect {|m| m.images.size > 1}
  visit borrow_model_path @model
end

Wenn(/^ich über ein solches Bild hovere$/) do
  page.execute_script %Q{ $("img[src='#{model_image_thumb_path(@model, offset: 0)}']").trigger("mouseenter") }
end

Dann(/^wird das Bild zum Hauptbild$/) do
  wait_until { not find("#main-image")["src"][model_image_path(@model, offset: 0)].blank? }
end

Wenn(/^ich über ein weiteres Bild hovere$/) do
  page.execute_script %Q{ $("img[src='#{model_image_thumb_path(@model, offset: 1)}']").trigger("mouseenter") }
end

Dann(/^wird dieses zum Hauptbild$/) do
  wait_until { not find("#main-image")["src"][model_image_path(@model, offset: 1)].blank? }
end

Wenn(/^ich ein Bild anklicke$/) do
  find("img[src='#{model_image_thumb_path(@model, offset: 1)}']").click
end

Dann(/^wird das Bild zum Hauptbild auch wenn ich das hovern beende$/) do
  find("body").click
  wait_until { not find("#main-image")["src"][model_image_path(@model, offset: 1)].blank? }
end

Angenommen(/^man befindet sich in einer Modellübersicht mit Eigenschaften$/) do
  @model = @current_user.models.borrowable.detect {|m| m.properties.length > 5}
  visit borrow_model_path @model
end

Dann(/^werden die ersten fünf Eigenschaften mit Schlüssel und Wert angezeigt$/) do
  @model.properties[0..4].each do |property|
    find("*", :text => property.key, :visible => true)
  end
end

Dann(/^wenn man 'Alle Eigenschaften anzeigen' wählt$/) do
  find("#properties-toggle").click
end

Dann(/^werden alle weiteren Eigenschaften angezeigt$/) do
  find("#collapsed-properties")["class"]["collapsed"].nil?.should be_true
end

Dann(/^man kann an derselben Stelle die Eigenschaften wieder zuklappen$/) do
  find("#properties-toggle").click
  find("#collapsed-properties")["class"]["collapsed"].nil?.should be_false
end
