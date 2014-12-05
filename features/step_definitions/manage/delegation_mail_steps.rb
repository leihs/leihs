# -*- encoding : utf-8 -*-

Angenommen(/^es existiert eine Bestellung von einer Delegation die nicht von einem Delegationsverantwortlichen erstellt wurde$/) do
  @contract = @current_inventory_pool.contracts.submitted.where(user_id: User.as_delegations).sample
  expect(@contract.user.delegator_user).not_to eq @contract.delegated_user
  expect(ActionMailer::Base.deliveries.count).to eq 0
end

Dann(/^wird das Genehmigungsmail an den Besteller versendet$/) do
  expect(ActionMailer::Base.deliveries.count).to eq 1
  expect(ActionMailer::Base.deliveries.first.to).to eq  @contract.delegated_user.emails
end

Dann(/^das Genehmigungsmail wird nicht an den Delegationsverantwortlichen versendet$/) do
  expect((ActionMailer::Base.deliveries.first.to & @contract.user.delegator_user.emails).empty?).to be true
end

Angenommen(/^es existiert eine Rücknahme von einer Delegation$/) do
  @contract = @current_inventory_pool.contracts.signed.where(user_id: User.as_delegations).sample
  expect(@contract.user.delegator_user).not_to eq @contract.delegated_user
  expect(ActionMailer::Base.deliveries.count).to eq 0
end

Wenn(/^ich bei dieser Rücknahme eine Erinnerung sende$/) do
  step "I navigate to the take back visits"
  within(".line", text: /#{@contract.user}.*#{_("Latest reminder")}/) do
    find(".arrow.down").click
    find("a", text: _("Send reminder")).click
  end
end

Dann(/^wird das Erinnerungsmail an den Abholenden versendet$/) do
  find(".line", text: /#{@contract.user}.*#{_("Reminder sent")}/)
  step "wird das Genehmigungsmail an den Besteller versendet"
end

Dann(/^das Erinnerungsmail wird nicht an den Delegationsverantwortlichen versendet$/) do
  step "das Genehmigungsmail wird nicht an den Delegationsverantwortlichen versendet"
end

Wenn(/^ich die Mailfunktion wähle$/) do
  expect(ActionMailer::Base.deliveries.count).to eq 0
  within("#users .line", text: @delegation) do
    find(".arrow.down").click
    @mailto_link = find("a", text: _("E-Mail"))[:href]
  end
end

Dann(/^wird das Mail an den Delegationsverantwrotlichen verschickt$/) do
  expect(@mailto_link).to eq "mailto:%s" % @delegation.delegator_user.email
end
