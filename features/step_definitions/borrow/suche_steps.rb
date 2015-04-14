# -*- encoding : utf-8 -*-

#Dann(/^sieht man die Suche$/) do
Then(/^I can see the search box$/) do
  visit borrow_root_path
  expect(has_selector?(".topbar .topbar-search")).to be true
end

# Wenn(/^man einen Suchbegriff eingibt$/) do
#   step 'man gibt einen Suchbegriff ein'
# end

#Dann(/^sieht man das Foto, den Namen und den Hersteller der ersten 6 Modelle gemäss aktuellem Suchbegriff$/) do
Then(/^I see image, name and manufacturer of the first 6 matching models$/) do
  within "#search-autocomplete" do
    within ".ui-autocomplete" do
      find(".ui-autocomplete a", match: :first)
      matches = all(".ui-autocomplete a")
      expect(matches.length).to be >= 6
      matches[0,6].each do |match|
        within match do
          text = find("strong", text: @search_term).text
          model = @current_user.models.borrowable.find {|m| [m.name, m.product].include? text }
          find("div > div:nth-child(2)", text: model.manufacturer)
          find("div > img[src='/models/#{model.id}/image_thumb']")
        end
      end
    end
  end
end

#Dann(/^sieht den Link 'Alle Suchresultate anzeigen'$/) do
Then(/^I see a link labeled 'Show all search results'$/) do
  expect(has_selector?(".ui-autocomplete a", :text => _("Show all search results"))).to be true
end

#Angenommen(/^man wählt ein Modell von der Vorschlagsliste der Suche$/) do
Given(/^I pick a model from the ones suggested$/) do
  #step 'man einen Suchbegriff eingibt'
  step 'I enter a search term'
  @model = @current_user.models.find {|m| [m.name, m.product].include? find(".ui-autocomplete a strong", match: :first).text }
  find(".ui-autocomplete a", match: :first, :text => @model.name).click
end

#Dann(/^wird die Modell\-Ansichtsseite geöffnet$/) do
Then(/^I see the model's detail page$/) do
  expect(current_path).to eq borrow_model_path(@model)
end

#Angenommen(/^man gibt einen Suchbegriff ein$/) do
Given(/^I enter a search term$/) do
  @model ||= @current_user.models.borrowable.detect {|m| @current_user.models.borrowable.where("models.product LIKE '%#{m.name[0..3]}%'").length >= 6}
  @search_term = @model.name[0..3]
  fill_in "search_term", :with => @search_term
end

When(/^I search for models giving at least two space separated terms$/) do
  @models = @current_user.models.borrowable.where.not(product: nil).where.not(version: nil)
  @search_term = @models.order("RAND()").first.name
  expect(@search_term.split(' ').size).to be >= 2
  fill_in "search_term", :with => @search_term
end

#Angenommen(/^drückt ENTER$/) do
Given(/^I press the Enter key$/) do
  find("#search input[name='search_term']").native.send_keys(:return)
end

#Dann(/^wird die Such\-Resultatseite angezeigt$/) do
Then(/^the search result page is shown$/) do
  find("nav .navigation-tab-item.active span[title=\"%s\"]" % _("Search for '%s'") % @search_term)
  expect(current_path).to eq borrow_search_results_path
end

#Dann(/^man sieht alle gefundenen Modelle mit Bild, Modellname und Herstellername$/) do
Then(/^I see image, name and manufacturer of all matching models$/) do
  @models = @current_user.models.borrowable.search(@search_term, [:manufacturer, :product, :version]).default_order.paginate(page: 1, per_page: 20)
  @models.each do |model|
    within "#model-list .line[data-id='#{model.id}']" do
      find("div .col1of6", :text => model.manufacturer, match: :prefer_exact)
      find("div .col3of6", :text => model.name, match: :prefer_exact)
      find("div .col1of6 img[src='/models/#{model.id}/image_thumb']")
    end
  end
end

#Dann(/^man sieht die Sortiermöglichkeit$/) do
#  step 'man sieht Sortiermöglichkeiten'
#end

#Dann(/^man sieht die Geräteparkeinschränkung$/) do
#  step 'man sieht die Gerätepark-Auswahl'
#end

#Dann(/^man sieht die Ausleihzeitraumwahl$/) do
#  step 'man sieht die Einschränkungsmöglichkeit eines Ausleihzeitraums'
#end

#Dann(/^die Vorschlagswerte sind verschwunden$/) do
Then(/^the suggestions have disappeared$/) do
  expect(has_no_selector?(".ui-autocomplete")).to be true
end

#Wenn(/^ich nach einem Modell suche, welches in nicht ausleihen kann$/) do
When(/^I search for a model that I can't borrow$/) do
  @model = (@current_user.models.order("RAND()") - @current_user.models.borrowable).first
end

#Dann(/^wird dieses Modell auch nicht in den Suchergebnissen angezeigt$/) do
Then(/^that model is not shown in the search results$/) do
  #step 'man einen Suchbegriff eingibt'
  step 'I enter a search term'
  expect(has_no_content?(@model.name)).to be true
  #step 'drückt ENTER'
  step 'I press the Enter key'
  expect(has_no_content?(@model.name)).to be true
end
