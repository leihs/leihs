# -*- encoding : utf-8 -*-

Angenommen(/^es existiert eine Bestellung von einer Delegation die nicht von einem Delegationsverantwortlichen erstellt wurde$/) do
  @contract = @current_inventory_pool.contracts.submitted.where(user_id: User.as_delegations).sample
  @contract.user.delegator_user.should_not == @contract.delegated_user
  ActionMailer::Base.deliveries.count.should == 0
end

Dann(/^wird das Genehmigungsmail an den Besteller versendet$/) do
  ActionMailer::Base.deliveries.count.should == 1
  ActionMailer::Base.deliveries.first.to.should ==  @contract.delegated_user.emails
end

Dann(/^das Genehmigungsmail wird nicht an den Delegationsverantwortlichen versendet$/) do
  (ActionMailer::Base.deliveries.first.to & @contract.user.delegator_user.emails).should be_empty
end

Angenommen(/^es existiert eine Rücknahme von einer Delegation$/) do
  @contract = @current_inventory_pool.contracts.signed.where(user_id: User.as_delegations).sample
  @contract.user.delegator_user.should_not == @contract.delegated_user
  ActionMailer::Base.deliveries.count.should == 0
end

Wenn(/^ich bei dieser Rücknahme eine Erinnerung sende$/) do
  find("[data-collapsed-toggle='#take_backs']").click if page.has_selector?("[data-collapsed-toggle='#take_backs']")
  within("#take_backs .line", text: /#{@contract.user}.*#{_("Latest reminder")}/) do
    find(".arrow.down").hover
    find("a", text: _("Send reminder")).click
  end
end

Dann(/^wird das Erinnerungsmail an den Abholenden versendet$/) do
  find("#take_backs .line", text: /#{@contract.user}.*#{_("Reminder sent")}/)
  step "wird das Genehmigungsmail an den Besteller versendet"
end

Dann(/^das Erinnerungsmail wird nicht an den Delegationsverantwortlichen versendet$/) do
  step "das Genehmigungsmail wird nicht an den Delegationsverantwortlichen versendet"
end

Wenn(/^ich die Mailfunktion wähle$/) do
  ActionMailer::Base.deliveries.count.should == 0
  within("#users .line", text: @delegation) do
    find(".arrow.down").hover
    @mailto_link = find("a", text: _("E-Mail"))[:href]
  end
end

Dann(/^wird das Mail an den Delegationsverantwrotlichen verschickt$/) do
  @mailto_link.should == "mailto:%s" % @delegation.delegator_user.email
end
