# -*- encoding : utf-8 -*-

#Angenommen(/^es existiert eine Bestellung von einer Delegation die nicht von einem Delegationsverantwortlichen erstellt wurde$/) do
#Angenommen(/^es existiert eine Rücknahme von einer Delegation$/) do
Given(/^there is (an order|a take back) for a delegation that was not placed by a person responsible for that delegation$/) do |arg1|
  status = case arg1
             when "an order"
               :submitted
             when "a take back"
               :signed
           end
  @current_inventory_pool = @current_user.inventory_pools.managed.detect do |ip|
    User.as_delegations.detect do |delegation|
      @contract = ip.reservations_bundles.send(status).where(user_id: delegation).where.not(delegated_user_id: delegation.delegator_user).order('RAND()').first
    end
  end
  expect(@contract).not_to be_nil
  expect(@contract.user.delegator_user).not_to eq @contract.delegated_user
  expect(ActionMailer::Base.deliveries.count).to eq 0
end

#Dann(/^wird das Genehmigungsmail an den Besteller versendet$/) do
Then(/^the approval email is sent to the orderer$/) do
  expect(ActionMailer::Base.deliveries.count).to eq 1
  expect(ActionMailer::Base.deliveries.first.to).to eq  @contract.delegated_user.emails
end

#Dann(/^das Genehmigungsmail wird nicht an den Delegationsverantwortlichen versendet$/) do
Then(/^the approval email is not sent to the delegated user$/) do
  expect((ActionMailer::Base.deliveries.first.to & @contract.user.delegator_user.emails).empty?).to be true
end

# Wenn(/^ich bei dieser Rücknahme eine Erinnerung sende$/) do
When(/^I send a reminder for this take back$/) do
  step "I navigate to the take back visits"
  within(".line", text: /#{@contract.user}.*#{_("Latest reminder")}/) do
    find(".arrow.down").click
    find("a", text: _("Send reminder")).click
  end
end

#Dann(/^wird das Erinnerungsmail an den Abholenden versendet$/) do
Then(/^the reminder is sent to the one who picked up the order$/) do
  find(".line", text: /#{@contract.user}.*#{_("Reminder sent")}/)

  #step "wird das Genehmigungsmail an den Besteller versendet"
  step "the approval email is sent to the orderer"
end

#Dann(/^das Erinnerungsmail wird nicht an den Delegationsverantwortlichen versendet$/) do
Then(/^the reminder is not sent to the delegated user$/) do
  #step "das Genehmigungsmail wird nicht an den Delegationsverantwortlichen versendet"
  step "the approval email is not sent to the delegated user"
end

#Wenn(/^ich die Mailfunktion wähle$/) do
When(/^I choose the mail function$/) do
  expect(ActionMailer::Base.deliveries.count).to eq 0
  within("#users .line", text: @delegation) do
    find(".arrow.down").click
    @mailto_link = find("a", text: _("E-Mail"))[:href]
  end
end

#Dann(/^wird das Mail an den Delegationsverantwrotlichen verschickt$/) do
Then(/^the email is sent to the delegator user$/) do
  expect(@mailto_link).to eq "mailto:%s" % @delegation.delegator_user.email
end
