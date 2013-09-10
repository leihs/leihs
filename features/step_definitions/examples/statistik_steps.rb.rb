# encoding: utf-8

Wenn(/^ich im Verwalten\-Bereich bin$/) do
  visit backend_path
end

Dann(/^habe ich die Möglichkeit zur Statistik\-Ansicht zu wechseln$/) do
  find("a[href='#{statistics_path}']")
end
