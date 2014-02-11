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
  find("[data-order-approve]").click
end

Dann(/^ist es mir nicht möglich, die Genehmigung zu forcieren$/) do
  page.has_selector? ".modal"
  if all(".modal .multibutton .dropdown-toggle").length > 0
    find(".modal .multibutton .dropdown-toggle").click
  end
  page.has_no_text? _("Approve anyway")
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
  @contract = @current_inventory_pool.contracts.with_verifiable_user_and_model.first
  @contract.should_not be_nil
end

Dann(/^wurde diese Bestellung von einem Benutzer aus einer visierpflichtigen Gruppe erstellt$/) do
  @current_inventory_pool.groups.where(is_verification_required: true).flat_map(&:users).uniq.include? @contract.user
end

Dann(/^diese Bestellung beinhaltet ein Modell aus einer visierpflichtigen Gruppe$/) do
  @contract.models.any? do |m|
    @current_inventory_pool.groups.where(is_verification_required: true).flat_map(&:models).uniq.include? m
  end
end

Wenn(/^ich den Reiter "(.*?)" einsehe$/) do |tab|
  find(".inline-tab-navigation .inline-tab-item", text: tab).click
end

Dann(/^sehe ich alle visierpflichtigen Bestellungen$/) do
  find("footer").click
  @contracts = @current_inventory_pool.contracts.where(status: [:submitted, :approved, :rejected]).with_verifiable_user_and_model
  @contracts.each {|c| page.has_selector? "[data-type='contract'][data-id='#{c.id}']"}
end

Dann(/^diese Bestellungen sind nach Erstelltdatum aufgelistet$/) do
  @contracts.order("created_at DESC").first.id.to_s.should == all("[data-type='contract']").first["data-id"]
  @contracts.order("created_at DESC").last.id.to_s.should == all("[data-type='contract']").last["data-id"]
end

Dann(/^sehe ich alle offenen visierpflichtigen Bestellungen$/) do
  find("footer").click
  @contracts = @current_inventory_pool.contracts.where(status: :submitted).with_verifiable_user_and_model
  @contracts.each {|c| page.has_selector? "[data-type='contract'][data-id='#{c.id}']"}
  @contract = @contracts.order("created_at DESC").first
  @line_css =  "[data-type='contract'][data-id='#{@contract.id}']"
end

Dann(/^ich sehe auf der Bestellungszeile den Besteller mit Popup\-Ansicht der Benutzerinformationen$/) do
  find(@line_css).has_text? @contract.user.name
  find("[data-firstname][data-id='#{@contract.user.id}']").hover
  page.has_css? ".tooltipster", text: @contract.user.name
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
  @contract.models.each {|m| page.has_css? ".tooltipster", text: m.name}
end

Dann(/^ich sehe auf der Bestellungszeile die Dauer der Bestellung$/) do
  find(@line_css).text.should include "#{@contract.max_range} #{n_("Day", "Days", @contract.max_range)}"
end

Dann(/^ich sehe auf der Bestellungszeile den Zweck$/) do
  find(@line_css).text.should include @contract.purpose.to_s
end

Dann(/^ich kann die Bestellung genehmigen$/) do
  find(@line_css).has_css? "[data-order-approve]"
end

Dann(/^ich kann die Bestellung ablehnen$/) do
  find(@line_css).has_css? "[data-order-reject]", visible: false
end

Dann(/^ich kann die Bestellung editieren$/) do
  find(@line_css).has_css? "[href*='#{manage_edit_contract_path(@current_inventory_pool, @contract)}']", visible: false
end

Dann(/^ich kann keine Bestellungen aushändigen$/) do
  find(@line_css).has_no_css? "[href*='#{manage_hand_over_contract_path(@current_inventory_pool, @contract)}']", visible: false
end

Dann(/^sehe ich alle genehmigten visierpflichtigen Bestellungen$/) do
  find("footer").click
  @contracts = @current_inventory_pool.contracts.where(status: :approved).with_verifiable_user_and_model
  @contracts.each {|c| page.has_selector? "[data-type='contract'][data-id='#{c.id}']"}
  @contract = @contracts.order("created_at DESC").first
  @line_css =  "[data-type='contract'][data-id='#{@contract.id}']"
end

Dann(/^ich sehe auf der Bestellungszeile den Status$/) do
  find(@line_css).text.should include _(@contract.status.to_s.capitalize)
end

Dann(/^sehe ich alle abgelehnten visierpflichtigen Bestellungen$/) do
  find("footer").click
  @contracts = @current_inventory_pool.contracts.where(status: :rejected).with_verifiable_user_and_model
  @contracts.each {|c| page.has_selector? "[data-type='contract'][data-id='#{c.id}']"}
  @contract = @contracts.order("created_at DESC").first
  @line_css =  "[data-type='contract'][data-id='#{@contract.id}']"
end

Angenommen(/^ich sehe alle visierpflichtigen Bestellungen$/) do
  step "sehe ich alle visierpflichtigen Bestellungen"
end

Wenn(/^ich den Filter "(.*?)" aufhebe$/) do |filter|
  uncheck filter
end

Dann(/^sehe ich alle Bestellungen, welche von Benutzern der visierpflichtigen Gruppen erstellt wurden$/) do
  find("footer").click
  @contracts = @current_inventory_pool.contracts.where(status: [:submitted, :rejected, :signed]).with_verifiable_user
  @contracts.each {|c| page.has_selector? "[data-type='contract'][data-id='#{c.id}']"}
end

Dann(/^ist die Bestellung wieder im Status noch nicht genehmigt$/) do
  find(@line_css).has_text? _("Approved")
  @contract.reload.status.should == :submitted
end
