# encoding: utf-8

Wenn(/^ich im Verwalten\-Bereich bin$/) do
  visit manage_root_path
end

Dann(/^habe ich die Möglichkeit zur Statistik\-Ansicht zu wechseln$/) do
  first("a[href='#{statistics_path}']")
end
