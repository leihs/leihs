# -*- encoding : utf-8 -*-

Angenommen(/^ich sehe die Sprachauswahl$/) do
  find("footer a[href*='locale']", match: :first)
end

Wenn(/^ich die Sprache ändere$/) do
  find("footer a[href*='locale']", :text => 'English').click
end

Dann(/^ist die Sprache für mich geändert$/) do
  find("footer a[href='']", :text => 'English')
  sleep(0.11) # fix lazy request problem
end