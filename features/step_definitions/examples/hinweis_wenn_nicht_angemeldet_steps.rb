# -*- encoding : utf-8 -*-

Wenn /^versuche eine Aktion im Backend auszuführen obwohl ich abgemeldet bin$/ do
  step 'ich mache eine Aushändigung'
  page.execute_script %Q{ $.ajax({url: "/logout"}); }
  wait_until {find("#code",:visible => true)}
  find("#code",:visible => true).set "A B"
end

Dann /^werden ich auf die Startseite weitergeleitet$/ do
  wait_until {current_path == root_path}
end

Dann /^sehe einen Hinweis, dass ich nicht angemeldet bin$/ do
  page.should have_content _("You are not logged in.")
end