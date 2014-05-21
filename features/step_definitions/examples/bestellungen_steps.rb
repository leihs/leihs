# -*- encoding : utf-8 -*-

Angenommen(/^es existiert eine leere Bestellung$/) do
  @current_inventory_pool = @current_user.managed_inventory_pools.first
  @customer = @current_inventory_pool.users.find{|u| u.visits.hand_over.count == 0}
  visit manage_hand_over_path @current_inventory_pool, @customer
  @contract = @current_inventory_pool.contracts.approved.where(user_id: @customer.id).last
end

Dann(/^sehe ich diese Bestellung nicht in der Liste der Bestellungen$/) do
  find('a', text: _('Orders')).click
  page.should_not have_selector("[data-id='#{@contract.id}']")
end

When(/^ich öffne eine Bestellung von ein gesperrter Benutzer$/) do
  user = @current_inventory_pool.contracts.submitted.sample.user
  ensure_suspended_user(user, @current_inventory_pool)
  step 'ich öffne eine Bestellung von "%s"' % user
end

When(/^sehe ich neben seinem Namen den Sperrstatus 'Gesperrt!'$/) do
  find("span.darkred-text", text: "%s!" % _("Suspended"))
end

def ensure_suspended_user(user, inventory_pool)
  unless user.suspended?(inventory_pool)
    user.access_rights.active.where(inventory_pool_id: inventory_pool).first.update_attributes(suspended_until: Date.today + 1.year, suspended_reason: "suspended reason")
    user.suspended?(inventory_pool).should be_true
  end
end

Angenommen(/^eine Bestellung enhält überbuchte Modelle$/) do
  @contract = @current_inventory_pool.contracts.submitted.with_verifiable_user_and_model.detect {|c| not c.approvable?}
  @contract.should_not be_nil
end

Wenn(/^ich die Bestellung editiere$/) do
  visit manage_edit_contract_path(@current_inventory_pool, @contract)
end

Wenn(/^die Bestellung genehmige$/) do
  if page.should have_selector "button", text: _("Approve order")
    click_button _("Approve order")
  elsif page.should have_selector "button", text: _("Verify + approve order")
    click_button _("Verify + approve order")
  end
end

Dann(/^ist es mir nicht möglich, die Genehmigung zu forcieren$/) do
  page.should have_selector ".modal"
  if all(".modal .multibutton .dropdown-toggle").length > 0
    find(".modal .multibutton .dropdown-toggle").click
  end
  page.should_not have_content _("Approve anyway")
end

Wenn(/^ich befinde mich im Gerätepark mit visierpflichtigen Bestellungen$/) do
  @current_inventory_pool = @current_user.managed_inventory_pools.find {|ip| not ip.contracts.with_verifiable_user_and_model.empty? }
end

Wenn(/^ich mich auf der Liste der Bestellungen befinde$/) do
  visit manage_contracts_path(@current_inventory_pool, status: [:approved, :submitted, :rejected]) unless current_path == manage_contracts_path(@current_inventory_pool, status: [:approved, :submitted, :rejected])
end

Dann(/^sehe ich die Reiter "(.*?)"$/) do |tabs|
  within ".inline-tab-navigation" do
    tabs.split(", ").each do |tab|
      find(".inline-tab-item", text: tab)
    end
  end
end

Angenommen(/^es existiert eine visierpflichtige Bestellung$/) do
  @contract = Contract.with_verifiable_user_and_model.first
  @contract.should_not be_nil
end

Dann(/^wurde diese Bestellung von einem Benutzer aus einer visierpflichtigen Gruppe erstellt$/) do
  Group.where(is_verification_required: true).flat_map(&:users).uniq.include? @contract.user
end

Dann(/^diese Bestellung beinhaltet ein Modell aus einer visierpflichtigen Gruppe$/) do
  @contract.models.any? do |m|
    Group.where(is_verification_required: true).flat_map(&:models).uniq.include? m
  end
end

Wenn(/^ich den Reiter "(.*?)" einsehe$/) do |tab|
  find(".inline-tab-navigation .inline-tab-item", text: tab).click
end

Dann(/^sehe ich alle visierpflichtigen Bestellungen$/) do
  step 'man bis zum Ende der Liste fährt'
  @contracts = @current_inventory_pool.contracts.where(status: [:submitted, :approved, :rejected]).with_verifiable_user_and_model
  @contracts.each {|c| page.should have_selector "[data-type='contract'][data-id='#{c.id}']"}
end

Dann(/^diese Bestellungen sind nach Erstelltdatum aufgelistet$/) do
  @contracts.order("created_at DESC").map{|c| c.id.to_s }.should == all("[data-type='contract']").map{|x| x["data-id"]}
end

Dann(/^sehe ich alle offenen visierpflichtigen Bestellungen$/) do
  step 'man bis zum Ende der Liste fährt'
  @contracts = @current_inventory_pool.contracts.where(status: :submitted).with_verifiable_user_and_model
  @contracts.each {|c| page.should have_selector "[data-type='contract'][data-id='#{c.id}']"}
  @contract = @contracts.order("created_at DESC").first
  @line_css =  "[data-type='contract'][data-id='#{@contract.id}']"
end

Dann(/^ich sehe auf der Bestellungszeile den Besteller mit Popup\-Ansicht der Benutzerinformationen$/) do
  find(@line_css).has_text? @contract.user.name
  find("[data-firstname][data-id='#{@contract.user.id}']").hover
  page.should have_selector ".tooltipster-base", text: @contract.user.name
end

Dann(/^ich sehe auf der Bestellungszeile das Erstelldatum$/) do
  extend ActionView::Helpers::DateHelper
  text = if @contract.created_at.today?
           _("Today")
         elsif @contract.created_at.to_date == Date.yesterday
           _("one day ago")
         else
           # TODO translate properly
           "vor #{time_ago_in_words(@contract.created_at)}n"
         end
  find(@line_css, text: text)
end

Dann(/^ich sehe auf der Bestellungszeile die Anzahl Gegenstände mit Popup\-Ansicht der bestellten Gegenstände$/) do
  find("#{@line_css} [data-type='lines-cell']").text.should == "#{@contract.lines.count} #{n_("Item", "Items", @contract.lines.count)}"
  find("#{@line_css} [data-type='lines-cell']").hover
  @contract.models.each {|m| page.should have_selector ".tooltipster-base", text: m.name}
end

Dann(/^ich sehe auf der Bestellungszeile die Dauer der Bestellung$/) do
  find(@line_css).text.should include "#{@contract.max_range} #{n_("Day", "Days", @contract.max_range)}"
end

Dann(/^ich sehe auf der Bestellungszeile den Zweck$/) do
  find(@line_css).text.should include @contract.purpose.to_s
end

Dann(/^ich kann die Bestellung genehmigen$/) do
  find(@line_css).should have_selector "[data-order-approve]"
end

Dann(/^ich kann die Bestellung ablehnen$/) do
  find(@line_css).should have_selector "[data-order-reject]", visible: false
end

Dann(/^ich kann die Bestellung editieren$/) do
  find(@line_css).should have_selector "[href*='#{manage_edit_contract_path(@current_inventory_pool, @contract)}']", visible: false
end

Dann(/^ich kann keine Bestellungen aushändigen$/) do
  find(@line_css).has_no_css? "[href*='#{manage_hand_over_contract_path(@current_inventory_pool, @contract)}']", visible: false
end

Dann(/^sehe ich alle genehmigten visierpflichtigen Bestellungen$/) do
  step 'man bis zum Ende der Liste fährt'
  @contracts = @current_inventory_pool.contracts.where(status: :approved).with_verifiable_user_and_model
  @contracts.each {|c| page.should have_selector "[data-type='contract'][data-id='#{c.id}']"}
  @contract = @contracts.order("created_at DESC").first
  @line_css =  "[data-type='contract'][data-id='#{@contract.id}']"
end

Dann(/^ich sehe auf der Bestellungszeile den Status$/) do
  find(@line_css).text.should include _(@contract.status.to_s.capitalize)
end

Dann(/^sehe ich alle abgelehnten visierpflichtigen Bestellungen$/) do
  step 'man bis zum Ende der Liste fährt'
  @contracts = @current_inventory_pool.contracts.where(status: :rejected).with_verifiable_user_and_model
  @contracts.each {|c| page.should have_selector "[data-type='contract'][data-id='#{c.id}']"}
  @contract = @contracts.order("created_at DESC").first
  @line_css =  "[data-type='contract'][data-id='#{@contract.id}']"
end

Wenn(/^ich den Filter "(.*?)" aufhebe$/) do |filter|
  uncheck filter
end

Dann(/^sehe ich alle Bestellungen, welche von Benutzern der visierpflichtigen Gruppen erstellt wurden$/) do
  step 'man bis zum Ende der Liste fährt'
  @contracts = @current_inventory_pool.contracts.where(status: [:submitted, :rejected, :signed]).with_verifiable_user
  @contracts.each {|c| page.should have_selector "[data-type='contract'][data-id='#{c.id}']"}
end

Dann(/^ist die Bestellung wieder im Status noch nicht genehmigt$/) do
  find(@line_css).has_text? _("Approved")
  @contract.reload.status.should == :submitted
end

Dann(/^ich eine bereits gehmigte Bestellung editiere$/) do
  find("#contracts .line[data-id]", match: :first)
  within all("#contracts .line[data-id]").sample do
    a = find("a", text: _("Editieren"))
    @target_url = a[:href]
    a.click
  end
end

Dann(/^gelange ich in die Ansicht der Aushändigung$/) do
  find("#hand-over-view")
  current_url.should == @target_url
end

Aber(/^ich kann nicht aushändigen$/) do
  find("[data-line-type='item_line']", match: :first)
  all("[data-line-type='item_line'] input[type='checkbox'][checked]").each &:click
  unless page.has_selector?("[data-hand-over-selection][disabled]")
    find("[data-hand-over-selection]").click
    find("#purpose").set Faker::Lorem.paragraph
    find("#note").set Faker::Lorem.paragraph
    find("button.green[data-hand-over]").click
    find("#error", text: _("You don't have permission to perform this action"))
  end
end

Dann(/^ich kann Modelle hinzufügen$/) do
  model = @current_inventory_pool.models.sample
  find("input#assign-or-add-input").set model.to_s
  find("form#assign-or-add .ui-menu-item a:not(.red)", match: :first).click
  find("#flash .notice", text: _("Added %s") % model)
end

Dann(/^ich kann Optionen hinzufügen$/) do
  option = @current_inventory_pool.options.sample
  find("input#assign-or-add-input").set option.to_s
  find("form#assign-or-add .ui-menu-item a", match: :first).click
  find("#flash .notice", text: _("Added %s") % option)
end

Aber(/^ich kann keine Gegenstände zuteilen$/) do
  find("[data-line-type='item_line']", match: :first)
  within all("[data-line-type='item_line']").sample do
    find("input[data-assign-item]").click
    find("li.ui-menu-item a", match: :first).click
  end
  find("#flash .error", text: _("You don't have permission to perform this action"))
end
