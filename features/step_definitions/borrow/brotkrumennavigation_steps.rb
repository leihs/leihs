# encoding: utf-8

Dann(/^sehe ich die Brotkrumennavigation$/) do
  page.should have_selector "nav .navigation-tab-item", text: _("Overview")
end

Angenommen(/^ich sehe die Brotkrumennavigation$/) do
  step "sehe ich die Brotkrumennavigation"
end

Dann(/^beinhaltet diese immer an erster Stelle das Übersichtsbutton$/) do
  @home_button = all("nav .navigation-tab-item").first
  @home_button.text.should match _("Overview")
end

Dann(/^dieser führt mich immer zur Seite der Hauptkategorien$/) do
  @home_button.click
  current_path.should eq borrow_start_path
end
