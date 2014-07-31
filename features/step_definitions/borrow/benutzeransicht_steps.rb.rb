# -*- encoding : utf-8 -*-

Wenn(/^ich auf meinen Namen klicke$/) do
  find("nav.topbar ul.topbar-navigation a[href='/borrow/user']", match: :first).click
end

Dann(/^gelange ich auf die Seite der Benutzerdaten$/) do
  expect(current_path).to eq borrow_current_user_path
end

Dann(/^werden mir meine Benutzerdaten angezeigt$/) do
  find("nav ul li a", match: :first, text: _("User data"))
end

Dann(/^die Benutzerdaten beinhalten$/) do |table|
  table.raw.flatten.each do |section|
    case section
      when "Vorname"
        expect(has_content?(_("First name"))).to be true
        expect(has_content?(@current_user.firstname)).to be true
      when "Nachname"
        expect(has_content?(_("Last name"))).to be true
        expect(has_content?(@current_user.lastname)).to be true
      when "E-Mail"
        expect(has_content?(_("Email"))).to be true
        expect(has_content?(@current_user.email)).to be true
      when "Telefon"
        expect(has_content?(_("Phone"))).to be true
        expect(has_content?(@current_user.phone)).to be true
      else
        raise "unkown section"
    end
  end
end

Wenn(/^ich über meinen Namen fahre$/) do
  find("nav.topbar ul.topbar-navigation a[href='/borrow/user']").hover
end

Dann(/^sehe ich im Dropdown eine Schaltfläche die zur Benutzeransicht führt$/) do
  find("ul.dropdown a.dropdown-item[href='/borrow/user']", text: _("User data")).click
  step "gelange ich auf die Seite der Benutzerdaten"
end

