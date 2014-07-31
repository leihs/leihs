# -*- encoding : utf-8 -*-

Wenn(/^ich die Sprache auf "(.*?)" umschalte$/) do |language|
  find("a[href*='locale']", match: :first, :text => language).click
end

Dann(/^ist die Sprache "(.*?)"$/) do |language|
  s = case language
        when "English"
          "en-GB"
        when "Deutsch"
          "de-CH"
  end
  expect(@current_user.reload.language.locale_name).to eq s
  find("a[href=''] strong", match: :first, :text => language)
end