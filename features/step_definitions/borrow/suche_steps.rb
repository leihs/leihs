# encoding: utf-8

Dann(/^sieht man die Suche$/) do
  visit borrow_start_path
  find(".topbar").find(".topbar-search")
end
