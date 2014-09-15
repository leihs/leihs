# -*- encoding : utf-8 -*-

Wenn(/^Julie in einer Delegation ist$/) do
  @user = Persona.get :julie
  expect(@user.delegations.empty?).to be false
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
  (@user.delegations & @current_inventory_pool.users).each do |u|
    find("#users .list-of-lines .line", match: :prefer_exact, text: u.to_s)
  end
  # TODO also check contracts matches, etc...
end

Dann(/^kann ich in der Benutzerliste nach Delegationen einschränken$/) do
  find("#user-index-view form#list-filters select#type").select _("Delegations")
  find("#user-list.list-of-lines .line", match: :first)
  ids = all("#user-list.list-of-lines .line [data-type='user-cell']").map {|user_data| user_data["data-id"] }
  expect(User.find(ids).all?(&:is_delegation)).to be true
end

Dann(/^ich kann in der Benutzerliste nach Benutzer einschränken$/) do
  find("#user-index-view form#list-filters select#type").select _("Users")
  find("#user-list.list-of-lines .line", match: :first)
  ids = all("#user-list.list-of-lines .line [data-type='user-cell']").map {|user_data| user_data["data-id"] }
  expect(User.find(ids).any?(&:is_delegation)).to be false
end

Angenommen(/^ich befinde mich im Reiter '(.*)'$/) do |arg1|
  find("nav ul li a.navigation-tab-item", text: arg1).click
  find("nav ul li a.navigation-tab-item.active", text: arg1)
  find("#user-index-view ")
end

Wenn(/^ich eine neue Delegation erstelle$/) do
  within(".multibutton", text: _("New User")) do
    find(".dropdown-toggle").click
    find(".dropdown-item", text: _("New Delegation")).click
  end
end

Wenn(/^ich der Delegation Zugriff für diesen Pool gebe$/) do
  find("select[name='access_right[role]']").select(_("Customer"))
end

Wenn(/^ich dieser Delegation einen Namen gebe$/) do
  @name = Faker::Lorem.sentence
  find("input[name='user[firstname]']").set @name
end

Wenn(/^ich dieser Delegation keinen, einen oder mehrere Personen zuteile$/) do
  @delegated_users = []
  rand(0..2).times do
    find("[data-search-users]").set " "
    find("ul.ui-autocomplete")
    el = all("ul.ui-autocomplete > li").to_a.sample
    @delegated_users << el.text
    el.click
  end
end

Wenn(/^ich kann dieser Delegation keine Delegation zuteile$/) do
  find("[data-search-users]").set @current_inventory_pool.users.as_delegations.sample.name
  sleep(0.33)
  expect(all("ul.ui-autocomplete > li").empty?).to be true
end

Wenn(/^ich genau einen Verantwortlichen eintrage$/) do
  @responsible ||= @current_inventory_pool.users.not_as_delegations.sample
  find(".row.emboss", text: _("Responsible")).find("input[data-type='autocomplete']").set @responsible.name
  find("ul.ui-autocomplete > li").click
end

Dann(/^ist die neue Delegation mit den aktuellen Informationen gespeichert$/) do
  delegation = User.find_by_firstname(@name)
  expect(delegation.delegator_user).to eq @responsible
  delegation.delegated_users.each {|du| @delegated_users.include? du.name}
  delegation.delegated_users.count == (@delegated_users + [@resonsible]).uniq.count
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
  @current_user.delegations.customers.each do |delegation|
    find(".line strong", match: :prefer_exact, text: delegation.to_s)
  end
end

Wenn(/^ich eine Delegation wähle$/) do
  within(all(".line").to_a.sample) do
    id = find(".line-actions a.button")[:href].gsub(/.*\//, '')
    @delegation = @current_user.delegations.customers.find(id)
    find("strong", match: :prefer_exact, text: @delegation.to_s)
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
    expect(contract.user).to eq @delegation
  end
end

Dann(/^ich werde als Kontaktperson hinterlegt$/) do
  @current_user.contracts.find(@contract_ids).each do |contract|
    expect(contract.delegated_user).to eq @delegated_user
  end
end

Angenommen(/^es wurde für eine Delegation eine Bestellung erstellt$/) do
  @contract = @current_inventory_pool.contracts.submitted.find {|c| c.user.is_delegation }
  expect(@contract).not_to be nil
end

Angenommen(/^ich befinde mich in dieser Bestellung$/) do
  visit manage_edit_contract_path @current_inventory_pool, @contract
end

Angenommen(/^ich befinde mich in einer Bestellung von einer Delegation$/) do
  @contract = @current_inventory_pool.contracts.find {|c| [:submitted, :approved].include? c.status and c.delegated_user and c.user.delegated_users.count >= 2}
  @delegation = @contract.user
  visit manage_edit_contract_path @current_inventory_pool, @contract
end

Dann(/^sehe ich den Namen der Delegation$/) do
  expect(has_content?(@contract.user.name)).to be true
end

Dann(/^ich sehe die Kontaktperson$/) do
  expect(has_content?(@contract.delegated_user.name)).to be true
end

Angenommen(/^es existiert eine persönliche Bestellung$/) do
  @contract = @current_inventory_pool.contracts.submitted.find {|c| not c.user.is_delegation }
  expect(@contract).not_to be nil
end

Dann(/^ist in der Bestellung der Name des Benutzers aufgeführt$/) do
  expect(has_content?(@contract.user.name)).to be true
end

Dann(/^ich sehe keine Kontatkperson$/) do
  expect(all("h2", text: @contract.user.name).size).to eq 1
end

Angenommen(/^es existiert eine Aushändigung( für eine Delegation)?( mit zugewiesenen Gegenständen)?$/) do |arg1, arg2|
  @hand_over = if arg1 and arg2
                 @current_inventory_pool.visits.hand_over.find {|v| v.user.is_delegation and v.lines.all?(&:item) and Date.today >= v.date }
               elsif arg1
                 @current_inventory_pool.visits.hand_over.find {|v| v.user.is_delegation and v.lines.any? &:item and not v.date.future? }
               else
                 @current_inventory_pool.visits.hand_over.sample
               end
  expect(@hand_over).not_to be nil
end

Angenommen(/^ich öffne diese Aushändigung$/) do
  visit manage_hand_over_path @current_inventory_pool, @hand_over.user
end

Wenn(/^ich die Delegation wechsle$/) do
  expect(has_selector?("input[data-select-lines]", match: :first)).to be true
  all("input[data-select-lines]").each {|el| el.click unless el.checked?}
  multibutton = first(".multibutton", text: _("Hand Over Selection")) || first(".multibutton", text: _("Edit Selection"))
  multibutton.find(".dropdown-toggle").click
  find("#swap-user", match: :first).click
  find(".modal", match: :first)
  @contract ||= @hand_over.lines.map(&:contract).uniq.first
  @old_delegation = @contract.user
  @new_delegation = @current_inventory_pool.users.find {|u| u.is_delegation and u.firstname != @old_delegation.firstname}
  find("input#user-id", match: :first).set @new_delegation.name
  find(".ui-menu-item a", match: :first).click
  @contract.lines.reload.all? {|c| c.user == @new_delegation }
end

Wenn(/^ich versuche die Delegation zu wechseln$/) do
  expect(has_selector?("input[data-select-lines]", match: :first)).to be true
  all("input[data-select-lines]").each_with_index do |line, i|
    el = all("input[data-select-lines]")[i]
    el.click unless el.checked?
  end
  multibutton = first(".multibutton", text: _("Hand Over Selection")) || first(".multibutton", text: _("Edit Selection"))
  multibutton.find(".dropdown-toggle").click
  find("#swap-user", match: :first).click
  find(".modal", match: :first)
  find("input#user-id", match: :first)
  @wrong_delegation = User.as_delegations.find {|d| not d.access_right_for @current_inventory_pool}
  @valid_delegation = @current_inventory_pool.users.as_delegations.sample
end

Dann(/^lautet die Aushändigung auf diese neu gewählte Delegation$/) do
  expect(has_content?(@new_delegation.name)).to be true
  expect(has_no_content?(@old_delegation.name)).to be true
end

Wenn(/^ich versuche die Kontaktperson zu wechseln$/) do
  expect(has_selector?("input[data-select-lines]", match: :first)).to be true
  all("input[data-select-lines]").each {|el| el.click unless el.checked?}
  find("button", text: _("Hand Over Selection")).click
  @delegation = @hand_over.user
  @contact = @delegation.delegated_users.sample
  @not_contact = @current_inventory_pool.users.find {|u| not @delegation.delegated_users.include? u}
end

Wenn(/^ich versuche bei der Bestellung die Kontaktperson zu wechseln$/) do
  click_button "swap-user"
  @contact = @delegation.delegated_users.sample
  @not_contact = @current_inventory_pool.users.find {|u| not @delegation.delegated_users.include? u}
end

Dann(/^kann ich nur diejenigen Personen wählen, die zur Delegationsgruppe gehören$/) do
  find("input#user-id", match: :first).set @not_contact.name
  expect(has_no_selector?(".ui-menu-item a")).to be true
  find("input#user-id", match: :first).set @contact.name
  find(".ui-menu-item a", match: :first, text: @contact.name).click
  find("#selected-user", text: @contact.name)
end

Dann(/^kann ich bei der Bestellung als Kontaktperson nur diejenigen Personen wählen, die zur Delegationsgruppe gehören$/) do
  within "#contact-person" do
    find("input#user-id", match: :first).set @not_contact.name
    expect(has_no_selector?(".ui-menu-item a")).to be true
    find("input#user-id", match: :first).set @contact.name
    find(".ui-menu-item a", match: :first, text: @contact.name).click
    find("#selected-user", text: @contact.name)
  end
end

Wenn(/^ich die Kontaktperson wechsle$/) do
  @contact ||= (@delegation or @new_delegation).delegated_users.sample
  within "#contact-person" do
    find("input#user-id", match: :first).set @contact.name
    find(".ui-menu-item a", match: :first, text: @contact.name).click
    find("#selected-user", text: @contact.name)
  end
end

Dann(/^kann ich nur diejenigen Delegationen wählen, die Zugriff auf meinen Gerätepark haben$/) do
  find("input#user-id", match: :first).set @wrong_delegation.name
  expect(has_no_selector?(".ui-menu-item a")).to be true
  find("input#user-id", match: :first).set @valid_delegation.name
  find(".ui-menu-item a", match: :first, text: @valid_delegation.name).click
  find("#selected-user", text: @valid_delegation.name)
end

Wenn(/^ich statt einer Delegation einen Benutzer wähle$/) do
  @contract ||= @hand_over.lines.map(&:contract).uniq.first
  @delegation = @contract.user
  @delegated_user = @contract.delegated_user
  @new_user = @current_inventory_pool.users.not_as_delegations.sample
  expect(has_selector?("input[data-select-lines]", match: :first)).to be true
  all("input[data-select-lines]").each_with_index do |line, i|
    el = all("input[data-select-lines]")[i]
    el.click unless el.checked?
  end
  multibutton = first(".multibutton", text: _("Hand Over Selection")) || first(".multibutton", text: _("Edit Selection"))
  multibutton.find(".dropdown-toggle").click if multibutton
  find("#swap-user", match: :first).click
  find(".modal", match: :first)
  find("#user input#user-id", match: :first).set @new_user.name
  find(".ui-menu-item a", match: :first, text: @new_user.name).click
  find(".modal .button[type='submit']", match: :first).click
end

Dann(/^ist in der Bestellung der Benutzer aufgeführt$/) do
  find(".content-wrapper", :text => @new_user.name, match: :first)
  expect(@contract.reload.user).to eq @new_user
end

Dann(/^es ist keine Kontaktperson aufgeführt$/) do
  expect(has_no_content?("(#{@delegated_user.name})")).to be true
  expect(@contract.reload.delegated_user).to eq nil
end

Wenn(/^keine Bestellung, Aushändigung oder ein Vertrag für eine Delegation besteht$/) do
  @delegations = User.as_delegations.select {|d| d.contracts.blank?}
end

Wenn(/^wenn für diese Delegation keine Zugriffsrechte für irgendwelches Gerätepark bestehen$/) do
  @delegation = @delegations.find {|d| d.access_rights.empty?}
  expect(@delegation).not_to be nil
end

Dann(/^kann ich diese Delegation löschen$/) do
  fill_in "list-search", with: @delegation.name
  line = find(".line", text: @delegation.name)
  line.find(".dropdown-toggle").click
  find("[data-method='delete']").click
  expect(has_selector?(".success")).to be true
  expect { @delegation.reload }.to raise_error ActiveRecord::RecordNotFound
end

Angenommen(/^ich in den Admin\-Bereich wechsle$/) do
  click_link _("Admin")
end

Dann(/^kann ich dieser Delegation ausschliesslich Zugriff als Kunde zuteilen$/) do
  roles = all("[name='access_right[role]'] option")
  expect(roles.size).to eq 2
  roles.include? "no_access"
  roles.include? "customer"
end

Wenn(/^ich keinen Verantwortlichen zuteile$/) do
  expect(find("input[name='user[delegator_user_id]']", visible: false)["value"].empty?).to be true
end

Dann(/^ich keinen Namen angebe$/) do
  find("input[name='user[firstname]']").set ""
end

Wenn(/^ich eine Delegation editiere$/) do
  @delegation = User.find {|u| u.is_delegation and u.delegated_users.exists? }
  visit manage_edit_inventory_pool_user_path(@current_inventory_pool, @delegation)
end

Wenn(/^ich den Verantwortlichen ändere$/) do
  @responsible = @current_inventory_pool.users.not_as_delegations.find {|u| u != @delegation.delegator_user }
  find(".row.emboss", text: _("Responsible")).find("input[data-type='autocomplete']").set @responsible.name
  find("ul.ui-autocomplete > li").click
end

Wenn(/^ich einen bestehenden Benutzer lösche$/) do
  @delegated_users = @delegation.delegated_users
  inline_user_entry = find(".row.emboss", text: _("Users")).find("[data-users-list] .row.line", match: :first)
  @removed_delegated_user = User.find {|u| u.name == inline_user_entry.find("[data-user-name]").text}
  inline_user_entry.find("button[data-remove-user]").click
  @delegated_users.delete @removed_delegated_user
end

Wenn(/^ich der Delegation einen neuen Benutzer hinzufüge$/) do
  find("[data-search-users]").set " "
  find("ul.ui-autocomplete")
  el = all("ul.ui-autocomplete > li").to_a.sample
  @delegated_users << User.find {|u| u.name == el.text}
  el.click
end

Dann(/^ist die bearbeitete Delegation mit den aktuellen Informationen gespeichert$/) do
  expect(@delegation.reload.delegator_user).to eq @responsible
  @delegation.delegated_users.each {|du| @delegated_users.include? du}
  @delegation.delegated_users.count == (@delegated_users + [@responsible]).uniq.count
  expect(@delegation.groups).to eq @current_inventory_pool.groups
end

Wenn(/^ich eine Delegation mit Zugriff auf das aktuelle Gerätepark editiere$/) do
  @delegation = @current_inventory_pool.users.find {|u| u.is_delegation and not u.visits.take_back.exists? and u.inventory_pools.count >= 2}
  expect(@delegation).not_to be nil
  visit manage_edit_inventory_pool_user_path(@current_inventory_pool, @delegation)
end

Wenn(/^ich dieser Delegation den Zugriff für den aktuellen Gerätepark entziehe$/) do
  @ip_name = @current_inventory_pool.name
  select _("No access"), from: "access_right[role]"
end

Dann(/^können keine Bestellungen für diese Delegation für dieses Gerätepark erstellt werden$/) do
  visit logout_path
  step %Q(I am logged in as '#{@delegation.delegator_user.login}' with password 'password')
  find(".dropdown-holder", text: @current_user.lastname).click
  find(".dropdown-item[href*='delegations']").click
  find(".row.line", text: @delegation.name).click_link _("Switch to")
  find(".topbar-item", text: _("Inventory Pools")).click
  expect(has_no_content?(@ip_name)).to be true
end

Wenn(/^ich eine Bestellung für eine Delegationsgruppe erstelle$/) do
  steps %{
    Wenn ich über meinen Namen fahre
    Und ich auf "Delegationen" drücke
    Dann werden mir die Delegationen angezeigt, denen ich zugeteilt bin
    Wenn ich eine Delegation wähle
    Dann wechsle ich die Anmeldung zur Delegation
    Angenommen man befindet sich auf der Modellliste
    Wenn man auf einem verfügbaren Model "Zur Bestellung hinzufügen" wählt
    Dann öffnet sich der Kalender
    Wenn alle Angaben die ich im Kalender mache gültig sind
    Dann lässt sich das Modell mit Start- und Enddatum, Anzahl und Gerätepark der Bestellung hinzugefügen
    Wenn ich die Bestellübersicht öffne
    Und ich einen Zweck eingebe
    Und man merkt sich die Bestellung
    Und ich die Bestellung abschliesse
    Und ich refreshe die Bestellung
    Dann ändert sich der Status der Bestellung auf Abgeschickt
    Und die Delegation ist als Besteller gespeichert
  }
end

Dann(/^bin ich die Kontaktperson für diesen Auftrag$/) do
  step "ich werde als Kontaktperson hinterlegt"
end

Wenn(/^ich die Gegenstände für die Delegation an "(.*?)" aushändige$/) do |contact_person|
  @contract = @delegation.contracts.submitted.first
  @contract.approve Faker::Lorem.sentence
  visit manage_hand_over_path(@current_inventory_pool, @delegation)
  sleep(0.33)
  expect(has_selector?("input[data-assign-item]")).to be true
  all("input[data-assign-item]").detect{|el| not el.disabled?}.click
  find(".ui-autocomplete .ui-menu-item", match: :first).click
  expect(has_selector? "[data-remove-assignment]").to be true
  find(".multibutton button[data-hand-over-selection]").click
  @contact = User.find_by_login(contact_person.downcase)
  step "ich die Kontaktperson wechsle"
  find("button[data-hand-over]").click
  expect(has_no_selector?(".modal button[data-hand-over]")).to be true
end

Dann(/^ist "(.*?)" die neue Kontaktperson dieses Auftrages$/) do |contact_person|
  expect(@delegation.contracts.signed.first.delegated_user).to eq @contact
end

Dann(/^ist in der Aushändigung der Benutzer aufgeführt$/) do
  find(".content-wrapper", :text => @new_user.name, match: :first)
  expect(current_path).to eq manage_hand_over_path(@current_inventory_pool, @new_user)
  expect(@delegation.visits.hand_over.blank?).to be true
end

Dann(/^ich öffne eine Aushändigung für eine Delegation$/) do
  @hand_over = @current_inventory_pool.visits.hand_over.find {|v| v.user.is_delegation }
  @delegation = @hand_over.user
  visit manage_hand_over_path @current_inventory_pool, @delegation
end

Wenn(/^ich statt eines Benutzers eine Delegation wähle$/) do
  @contract ||= @hand_over.lines.map(&:contract).uniq.first
  @user = @contract.user
  @delegation = @current_inventory_pool.users.as_delegations.sample
  expect(has_selector?("input[data-select-lines]", match: :first)).to be true
  all("input[data-select-lines]").each {|el| el.click unless el.checked?}
  multibutton = first(".multibutton", text: _("Hand Over Selection")) || first(".multibutton", text: _("Edit Selection"))
  multibutton.find(".dropdown-toggle").click if multibutton
  find("#swap-user", match: :first).click
  find(".modal", match: :first)
  find("#user input#user-id", match: :first).set @delegation.name
  find(".ui-menu-item a", match: :first, text: @delegation.name).click
end

Und(/^ich eine Kontaktperson aus der Delegation wähle$/) do
  @contact = @delegation.delegated_users.sample
  find("#contact-person input#user-id", match: :first).click
  find("#contact-person input#user-id", match: :first).set @contact.name
  find(".ui-menu-item a", match: :first, text: @contact.name).click
end

Dann(/^ist in der Bestellung der Name der Delegation aufgeführt$/) do
  expect(has_content?(@delegation.name)).to be true
end

Dann(/^ist in der Bestellung der Name der Kontaktperson aufgeführt$/) do
  expect(has_content?(@contact.name)).to be true
end

Dann(/^ich bestätige den Benutzerwechsel$/) do
  find(".modal button[type='submit']").click
end

Wenn(/^ich die Gegenstände aushändige$/) do
  line = find(".line[data-line-type='item_line'] input[id*='assigned-item'][value][disabled]", match: :first).find(:xpath, "ancestor::div[@data-line-type]")
  line.find("input[data-select-line]").click
  find(".multibutton", text: _("Hand Over Selection")).find("button").click
end

Dann(/^muss ich eine Kontaktperson hinzufügen$/) do
  find("button[data-hand-over]").click
  expect(has_selector?(".modal #contact-person")).to be true
  expect(find(".modal #error").text.empty?).to be false
end

Dann(/^die neu gewählte Kontaktperson wird gespeichert$/) do
  expect(@contract.reload.delegated_user).to eq @contact
end

Dann(/^sehe ich genau ein Kontaktpersonfeld$/) do
  expect(all("#contact-person").count).to eq 1
end

Wenn(/^ich keine Kontaktperson angebe$/) do
  expect(find("#contact-person input#user-id", match: :first).value.empty?).to be true
end

Wenn(/^ich den Benutzerwechsel bestätige$/) do
  step "ich bestätige den Benutzerwechsel"
end

Dann(/^sehe ich im Dialog die Fehlermeldung "(.*?)"$/) do |text|
  expect(has_selector?(".modal .red", text: text)).to be true
end

Wenn(/^ich die Aushändigung abschliesse$/) do
  find(:xpath, "//*[@data-line-type and descendant::*[contains(@id, 'assigned-item')]]//*[@data-select-line]", match: :first).click
  find("button[data-hand-over-selection]").click
end

Wenn(/^ich eine gesperrte Kontaktperson wähle$/) do
  delegated_user = @hand_over.user.delegated_users.select{|u| u.suspended? @current_inventory_pool}.sample
  delegated_user ||= begin
    user = @hand_over.user.delegated_users.sample
    ensure_suspended_user(user, @current_inventory_pool)
    user
  end
  find("input#user-id", match: :first).set delegated_user.name
  find(".ui-menu-item a", match: :first, text: delegated_user.name).click
end

Dann(/^muss ich eine Kontaktperson auswählen$/) do
  find(".modal [data-hand-over]").click
  within ".modal" do
    has_selector? ".red", text: _("Specification of the contact person is required")
  end
end

Angenommen(/^ich befinde mich in der Editieransicht einer Delegation$/) do
  @delegation = @current_inventory_pool.users.as_delegations.sample
  visit manage_edit_inventory_pool_user_path(@current_inventory_pool, @delegation)
end

Wenn(/^ich einen Verantwortlichen zuteile, der für diesen Gerätepark gesperrt ist$/) do
  @responsible = @current_inventory_pool.users.select{|u| u.suspended? @current_inventory_pool}.sample
  step 'ich genau einen Verantwortlichen eintrage'
end

Wenn(/^ich einen Benutzer hinzufüge, der für diesen Gerätepark gesperrt ist$/) do
  @delegated_user = @current_inventory_pool.users.select{|u| u.suspended? @current_inventory_pool}.sample
  @delegated_user ||= begin
      user = @current_inventory_pool.users.not_as_delegations.sample
      ensure_suspended_user(user, @current_inventory_pool)
      user
  end
  fill_in_autocomplete_field _("Users"), @delegated_user.name
end

Angenommen(/^ich wechsle den Benutzer$/) do
  click_button "swap-user"
  find(".modal", match: :first)
end

Angenommen(/^ich wähle eine Delegation$/) do
  @delegation = @current_inventory_pool.users.as_delegations.sample
  find("#user input#user-id", match: :first).set @delegation.name
  find(".ui-menu-item")
  find(".ui-menu-item a", match: :first, text: @delegation.name).click
end

Wenn(/^ich eine Kontaktperson wähle, der für diesen Gerätepark gesperrt ist$/) do
  delegated_user = @delegation.delegated_users.select{|u| u.suspended? @current_inventory_pool}.sample
  delegated_user ||= begin
    user = @delegation.delegated_users.sample
    ensure_suspended_user(user, @current_inventory_pool)
    user
  end
  find("input#user-id", match: :first).set delegated_user.name
  find(".ui-menu-item a", match: :first, text: delegated_user.name).click
end

Und(/^man merkt sich die Bestellung$/) do
  @contract = @current_user.contracts.unsubmitted.first
end

Und(/^ich refreshe die Bestellung$/) do
  @contract.reload
  @contract_ids = [@contract.id]
end
