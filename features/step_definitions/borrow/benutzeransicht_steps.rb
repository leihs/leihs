# -*- encoding : utf-8 -*-

#Dann(/^werden mir meine Benutzerdaten angezeigt$/) do
Then(/^I can see my user data$/) do
  find('nav ul li a', match: :first, text: _('User data'))
end

#Dann(/^die Benutzerdaten beinhalten$/) do |table|
Then(/^the user data consist of$/) do |table|
  table.raw.flatten.each do |section|
    case section
      when 'First name'
        expect(has_content?(_('First name'))).to be true
        expect(has_content?(@current_user.firstname)).to be true
      when 'Last name'
        expect(has_content?(_('Last name'))).to be true
        expect(has_content?(@current_user.lastname)).to be true
      when 'Email'
        expect(has_content?(_('Email'))).to be true
        expect(has_content?(@current_user.email)).to be true
      when 'Phone number'
        expect(has_content?(_('Phone'))).to be true
        expect(has_content?(@current_user.phone)).to be true
      else
        raise 'unkown section'
    end
  end
end
