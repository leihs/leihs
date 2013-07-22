# -*- encoding : utf-8 -*-

Wenn(/^ich die Sprache auf "(.*?)" umschalte$/) do |language|
  find("a[href*='locale']", :text => language).click
end

Dann(/^ist die Sprache English$/) do
  @current_user.reload.language.locale_name.should == "en-GB"
end