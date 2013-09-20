# -*- encoding : utf-8 -*-

Wenn /^versuche eine Aktion im Backend auszuführen obwohl ich abgemeldet bin$/ do
  step 'ich mache eine Aushändigung'
  page.execute_script %Q{ $.ajax({url: "/logout"}); }
  step "ensure there are no active requests"
  find("#code", match: :first).set "A B"
  step "ensure there are no active requests"
  sleep(0.88)
  sleep(0.88)
end

Dann /^werden ich auf die Startseite weitergeleitet$/ do
  current_path.should == root_path
end

Dann /^sehe einen Hinweis, dass ich nicht angemeldet bin$/ do
  page.should have_content _("You are not logged in.")
end
