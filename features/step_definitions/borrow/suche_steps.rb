# -*- encoding : utf-8 -*-

Dann(/^sieht man die Suche$/) do
  visit borrow_root_path
  find(".topbar").find(".topbar-search")
end

Wenn(/^man einen Suchbegriff eingibt$/) do
  step 'man gibt einen Suchbegriff ein'
end

Dann(/^sieht man das Foto, den Namen und den Hersteller der ersten 6 Modelle gemäss aktuellem Suchbegriff$/) do
  wait_until{find(".ui-autocomplete")}
  all(".ui-autocomplete a").length.should >= 6
  6.times do |i|
    find(:xpath, "(//*[contains(@class, 'ui-autocomplete')]//a)[#{i+1}]//strong").text[@search_term].should_not be_nil
    model = @current_user.models.borrowable.find_by_name find(:xpath, "(//*[contains(@class, 'ui-autocomplete')]//a)[#{i+1}]//strong").text
    find(:xpath, "(//*[contains(@class, 'ui-autocomplete')]//a)[#{i+1}]//*[contains(./text(), '#{model.manufacturer}')]")
    find(:xpath, "(//*[contains(@class, 'ui-autocomplete')]//a)[#{i+1}]//img[@src='/models/#{model.id}/image_thumb']")
  end
end

Dann(/^sieht den Link 'Alle Suchresultate anzeigen'$/) do
  find(".ui-autocomplete a", :text => _("Show all search results"))
end

Angenommen(/^man wählt ein Modell von der Vorschlagsliste der Suche$/) do
  step 'man einen Suchbegriff eingibt'
  @model = @current_user.models.find_by_name(find(".ui-autocomplete a strong").text)
  find(".ui-autocomplete a", :text => @model.name).click
end

Dann(/^wird die Modell\-Ansichtsseite geöffnet$/) do
  current_path.should eq borrow_model_path(@model)
end

Angenommen(/^man gibt einen Suchbegriff ein$/) do
  @model ||= @current_user.models.borrowable.detect {|m| @current_user.models.borrowable.where("models.name like '%#{m.name[0..3]}%'").length >= 6}
  @search_term = @model.name[0..3]
  fill_in "search_term", :with => @search_term
end

Angenommen(/^drückt ENTER$/) do
  find("#search input[name='search_term']").native.send_keys(:return)
end

Dann(/^wird die Such\-Resultatseite angezeigt$/) do
  current_path.should eq borrow_search_results_path(@model.name[0..3])
end

Dann(/^man sieht alle gefundenen Modelle mit Bild, Modellname und Herstellername$/) do
  @models = @current_user.models.borrowable
    .search(@model.name[0..3])
    .default_order.paginate(page: 1, per_page: 20)
    .map(&:name)
  @models.each do |model|
    find(".line", :text => @model.name)
    find(".line", :text => @model.manufacturer)
    find(".line img[src='/models/#{@model.id}/image_thumb']")
  end
end

Dann(/^man sieht die Sortiermöglichkeit$/) do
  step 'man sieht Sortiermöglichkeiten'
end

Dann(/^man sieht die Geräteparkeinschränkung$/) do
  step 'man sieht die Gerätepark-Auswahl'
end

Dann(/^man sieht die Ausleihzeitraumwahl$/) do
  step 'man sieht die Einschränkungsmöglichkeit eines Ausleihzeitraums'
end

Dann(/^die Vorschlagswerte sind verschwunden$/) do
  all(".ui-autocomplete").empty?.should be_true
end

Wenn(/^ich nach einem Modell suche, welches in nicht ausleihen kann$/) do
  @model = (@current_user.models - @current_user.models.borrowable).sample
end

Dann(/^wird dieses Modell auch nicht in den Suchergebnissen angezeigt$/) do
  step 'man einen Suchbegriff eingibt'
  page.should_not have_content @model.name
  step 'drückt ENTER'
  page.should_not have_content @model.name
end
