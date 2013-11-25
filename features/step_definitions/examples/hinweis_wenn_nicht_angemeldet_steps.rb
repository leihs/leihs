# -*- encoding : utf-8 -*-

Wenn /^versuche eine Aktion im Backend auszuführen obwohl ich abgemeldet bin$/ do
  step 'ich mache eine Aushändigung'
  page.execute_script %Q{ $.ajax({url: "/logout"}); }
  find("[data-add-contract-line]").set "A B"
  find("[data-add-contract-line]")
end

Dann /^werden ich auf die Startseite weitergeleitet$/ do
  find("#flash")
  current_path.should == root_path
end

Dann /^sehe einen Hinweis, dass ich nicht angemeldet bin$/ do
  page.should have_content _("You are not logged in.")
end
