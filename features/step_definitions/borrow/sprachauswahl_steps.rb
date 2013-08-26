# -*- encoding : utf-8 -*-

Angenommen(/^ich sehe die Sprachauswahl$/) do
  find("nav.navigation .item.language").click
end

Wenn(/^ich die Sprache ändere$/) do
  find("a[href*='locale']", :text => 'English').click
end

Dann(/^ist die Sprache für mich geändert$/) do
  find("nav.navigation .item.language").text.should == "English"
end