# -*- encoding : utf-8 -*-

#Wenn(/^ich auf meinen Namen klicke$/) do
When(/^I click on my name$/) do
  find("nav.topbar ul.topbar-navigation a[href='/borrow/user']", match: :first).click
end

#Dann(/^gelange ich auf die Seite der Benutzerdaten$/) do
#  step %Q(I get to the "User Data" page)
#end

#Dann(/^werden mir meine Benutzerdaten angezeigt$/) do
Then(/^I can see my user data$/) do
  find("nav ul li a", match: :first, text: _("User data"))
end

#Dann(/^die Benutzerdaten beinhalten$/) do |table|
Then(/^the user data consist of$/) do |table|
  table.raw.flatten.each do |section|
    case section
      when "First name"
        expect(has_content?(_("First name"))).to be true
        expect(has_content?(@current_user.firstname)).to be true
      when "Last name"
        expect(has_content?(_("Last name"))).to be true
        expect(has_content?(@current_user.lastname)).to be true
      when "Email"
        expect(has_content?(_("Email"))).to be true
        expect(has_content?(@current_user.email)).to be true
      when "Phone number"
        expect(has_content?(_("Phone"))).to be true
        expect(has_content?(@current_user.phone)).to be true
      else
        raise "unkown section"
    end
  end
end

#Wenn(/^ich über meinen Namen fahre$/) do
#  step "I hover over my name"
#end

#Dann(/^sehe ich im Dropdown eine Schaltfläche die zur Benutzeransicht führt$/) do
#  step "I view my user data"
#  step %Q(I get to the "User Data" page)
#end

