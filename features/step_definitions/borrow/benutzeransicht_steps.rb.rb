# -*- encoding : utf-8 -*-

Wenn(/^ich auf meinen Namen klicke$/) do
  find("nav.topbar ul.topbar-navigation a[href='/borrow/user']").click
end

Dann(/^gelange ich auf die Seite der Benutzerdaten$/) do
  current_path.should == borrow_current_user_path
end

Dann(/^werden mir meine Benutzerdaten angezeigt$/) do
  find("h1.headline-xl", text: _("User data"))
end

Dann(/^die Benutzerdaten beinhalten$/) do |table|
  table.raw.flatten.each do |section|
    case section
      when "Vorname"
        page.should have_content @current_user.firstname
      when "Nachname"
        page.should have_content @current_user.lastname
      when "E-Mail"
        page.should have_content @current_user.email
      when "Telefon"
        page.should have_content @current_user.phone
      else
        rais "unkown section"
    end
  end
end

Wenn(/^ich über meinen Namen fahre$/) do
  page.execute_script("$(\"nav.topbar ul.topbar-navigation a[href='/borrow/user']\").trigger('mouseover');")
end

Dann(/^sehe ich im Dropdown eine Schaltfläche die zur Benutzeransicht führt$/) do
  find("ul.dropdown a.dropdown-item[href='/borrow/user']", text: _("User data")).click
  step "gelange ich auf die Seite der Benutzerdaten"
end

