# -*- encoding : utf-8 -*-

Wenn(/^Julie in einer Delegation ist$/) do
  @user = Persona.get :julie
  @user.delegations.should_not be_empty
end

Dann(/^werden mir im alle Suchresultate von Julie oder Delegation mit Namen Julie angezeigt$/) do
  q = "%Julie%"
  delegations = @current_inventory_pool.users.as_delegations.where(User.arel_table[:firstname].matches(q))
  ([@user] + delegations).each do |u|
    find("#users .list-of-lines .line", match: :prefer_exact, text: u.to_s)
  end
  # TODO also check contracts matches, etc...
end

Dann(/^mir werden alle Delegationen angezeigt, den Julie zugeteilt ist$/) do
  @user.delegations.each do |u|
    find("#users .list-of-lines .line", match: :prefer_exact, text: u.to_s)
  end
  # TODO also check contracts matches, etc...
end

Dann(/^kann ich in der Benutzerliste nach Delegationen einschränken$/) do
  find("#user-index-view form#list-filters select#type").select _("Delegations")
  find("#user-list.list-of-lines .line", match: :first)
  ids = all("#user-list.list-of-lines .line [data-type='user-cell']").map {|user_data| user_data["data-id"] }
  User.find(ids).all?(&:is_delegation).should be_true
end

Dann(/^ich kann in der Benutzerliste nach Benutzer einschränken$/) do
  find("#user-index-view form#list-filters select#type").select _("Users")
  find("#user-list.list-of-lines .line", match: :first)
  ids = all("#user-list.list-of-lines .line [data-type='user-cell']").map {|user_data| user_data["data-id"] }
  User.find(ids).any?(&:is_delegation).should be_false
end

Angenommen(/^ich befinde mich im Reiter '(.*)'$/) do |arg1|
  find("nav ul li a.navigation-tab-item", text: arg1).click
  find("nav ul li a.navigation-tab-item.active", text: arg1)
  find("#user-index-view ")
end

Wenn(/^ich eine neue Delegation erstelle$/) do
  within(".multibutton", text: _("New User")) do
    find(".dropdown-toggle").hover
    find(".dropdown-item", text: _("New Delegation")).click
  end
  pending
end

Wenn(/^ich der Delegation Zugriff für diesen Pool gebe$/) do
  pending # express the regexp above with the code you wish you had
end

Wenn(/^ich dieser Delegation einen Namen gebe$/) do
  pending # express the regexp above with the code you wish you had
end

Wenn(/^ich dieser Delegation keinen, einen oder mehrere Personen zuteile$/) do
  pending # express the regexp above with the code you wish you had
end

Wenn(/^ich kann dieser Delegation keine Delegation zuteile$/) do
  pending # express the regexp above with the code you wish you had
end

Wenn(/^ich genau einen Verantwortlichen eintrage$/) do
  pending # express the regexp above with the code you wish you had
end

Wenn(/^ich die Delegation speichere$/) do
  pending # express the regexp above with the code you wish you had
end

Dann(/^ist die Delegation mit den aktuellen Informationen gespeichert$/) do
  pending # express the regexp above with the code you wish you had
end

Wenn(/^ich nach einer Delegation suche$/) do
  @delegation = @current_inventory_pool.users.as_delegations.sample
  step "ich suche '%s'" % @delegation.firstname
end

Wenn(/^ich über den Delegationname fahre$/) do
  find("#users .list-of-lines .line", match: :prefer_exact, text: @delegation.to_s).find("[data-type='user-cell']").hover
end

Dann(/^werden mir im Tooltipp der Name und der Verantwortliche der Delegation angezeigt$/) do
  find("body > .tooltipster-base", text: @delegation.delegator_user.to_s)
end

Dann(/^werden mir die Delegationen angezeigt, denen ich zugeteilt bin$/) do
  @current_user.delegations.each do |delegation|
    find(".line strong", match: :prefer_exact, text: delegation.to_s)
  end
end

Wenn(/^ich eine Delegation wähle$/) do
  within(all(".line").to_a.sample) do
    id = find(".line-actions a.button")[:href].gsub(/.*\//, '')
    @delegation = @current_user.delegations.find(id)
    find("strong", match: :prefer_exact, text: @new_delegation.to_s)
    find(".line-actions a.button").click
  end
end

Dann(/^wechsle ich die Anmeldung zur Delegation$/) do
  find("nav.topbar ul.topbar-navigation a[href='/borrow/user']", text: @delegation.short_name)
  @delegated_user = @current_user
  @current_user = @delegation
end

Dann(/^die Delegation ist als Besteller gespeichert$/) do
  @current_user.contracts.find(@contract_ids).each do |contract|
    contract.user.should == @delegation
  end
end

Dann(/^ich werde als Kontaktperson hinterlegt$/) do
  @current_user.contracts.find(@contract_ids).each do |contract|
    contract.delegated_user.should == @delegated_user
  end
end

Angenommen(/^es wurde für eine Delegation eine Bestellung erstellt$/) do
  @contract = @current_inventory_pool.contracts.find {|c| c.user.is_delegation }
  @contract.should_not be_nil
end

Angenommen(/^ich befinde mich in dieser Bestellung$/) do
  visit manage_edit_contract_path @current_inventory_pool, @contract
end

Dann(/^sehe ich den Namen der Delegation$/) do
  page.has_content? @contract.user.name
end

Dann(/^ich sehe die Kontaktperson$/) do
  page.has_content? @contract.delegated_user.name
end
