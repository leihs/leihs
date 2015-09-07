# -*- encoding : utf-8 -*-

Given(/^there is (an order|a take back|an overdue take back) for a delegation that was not placed by a person responsible for that delegation$/) do |arg1|
  status = case arg1
             when "an order"
               :submitted
             when "a take back", "an overdue take back"
               :signed
           end
  @current_inventory_pool = @current_user.inventory_pools.managed.detect do |ip|
    User.as_delegations.detect do |delegation|
      @contract = ip.reservations_bundles.send(status).where(user_id: delegation).where.not(delegated_user_id: delegation.delegator_user).order('RAND()').detect do |reservation_bundle|
        if arg1 == "an overdue take back"
          reservation_bundle.reservations.any? {|reservation| reservation.end_date < Date.today }
        else
          true
        end
      end
    end
  end
  expect(@contract).not_to be_nil
  expect(@contract.user.delegator_user).not_to eq @contract.delegated_user
  expect(ActionMailer::Base.deliveries.count).to eq 0
end

Then(/^the approval email is sent to the orderer$/) do
  expect(ActionMailer::Base.deliveries.count).to eq 1
  expect(ActionMailer::Base.deliveries.first.to).to eq  @contract.delegated_user.emails
end

Then(/^the approval email is not sent to the delegated user$/) do
  expect((ActionMailer::Base.deliveries.first.to & @contract.user.delegator_user.emails).empty?).to be true
end


When(/^I send a reminder for this take back$/) do
  step 'I navigate to the take back visits'
  within('.line', text: /#{@contract.user}.*#{_("Latest reminder")}/) do
    within '.multibutton' do
      find('.dropdown-toggle').click
      find('a', text: _('Send reminder')).click
    end
  end
end

Then(/^the reminder is sent to the one who picked up the order$/) do
  find('.line', text: /#{@contract.user}.*#{_("Reminder sent")}/)

  #step "wird das Genehmigungsmail an den Besteller versendet"
  step 'the approval email is sent to the orderer'
end

Then(/^the reminder is not sent to the delegated user$/) do
  #step "das Genehmigungsmail wird nicht an den Delegationsverantwortlichen versendet"
  step 'the approval email is not sent to the delegated user'
end

When(/^I choose the mail function$/) do
  expect(ActionMailer::Base.deliveries.count).to eq 0
  within('#users .line', text: @delegation) do
    find('.arrow.down').click
    @mailto_link = find('a', text: _('E-Mail'))[:href]
  end
end

Then(/^the email is sent to the delegator user$/) do
  expect(@mailto_link).to eq 'mailto:%s' % @delegation.delegator_user.email
end
