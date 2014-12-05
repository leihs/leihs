When(/^I open the calendar of a model$/) do
  model = (@inventory_pool.models & @current_user.models.borrowable).sample
  visit borrow_model_path(model)
  find("[data-create-order-line][data-model-id='#{model.id}']").click
end

Given(/^the current inventory pool has reached maximum amount of visits$/) do
  if @current_inventory_pool.workday.reached_max_visits.empty?
    # NOTE set max visits to 1 for all days
    @current_inventory_pool.workday.update_attributes(max_visits: (0..6).inject({}) { |h, n| h[n] = 1; h })
  end
  expect(@current_inventory_pool.workday.reached_max_visits).not_to be_empty
end

When(/^I open the calendar of a model related to an inventory pool for which has reached maximum amount of visits$/) do
  @inventory_pool = @current_user.inventory_pools.shuffle.detect { |ip| not ip.workday.reached_max_visits.empty? }
  @inventory_pool ||= @current_user.inventory_pools.detect do |ip|
    if ip.visits.where("date >= ?", Date.today)
      # NOTE set max visits to 1 for all days
      ip.workday.update_attributes(max_visits: (0..6).inject({}) { |h, n| h[n] = 1; h })
      true
    else
      false
    end
  end
  step "I open the calendar of a model"
end

When(/^I open the calendar of a model related to an inventory pool for which the number of days between order submission and hand over is defined as (\d+)$/) do |arg1|
  @inventory_pool = @current_user.inventory_pools.shuffle.detect { |ip| ip.workday.reservation_advance_days == arg1.to_i }
  @inventory_pool ||= begin
    ip = @current_user.inventory_pools.sample
    ip.workday.update_attributes(reservation_advance_days: arg1.to_i)
    ip
  end
  step "I open the calendar of a model"
end

When(/^I select that inventory pool$/) do
  within ".modal" do
    within "#booking-calendar-inventory-pool" do
      find("option[data-id='#{@inventory_pool.id}']", text: @inventory_pool.name).click
    end
  end
end

Then(/^(the|no) availability number is shown (.*)$/) do |arg1, arg2|
  dates = case arg2
            when "on this specific date"
              (@current_inventory_pool || @inventory_pool).workday.reached_max_visits
            when "for today"
              Date.today
            when "for tomorrow"
              Date.tomorrow
            when "for the next open day after tomorrow"
              (@current_inventory_pool || @inventory_pool).next_open_date(Date.tomorrow + 1.day)
            else
              raise
          end
  within ".modal" do
    Array(dates).each do |date|
      while has_no_selector?(".fc-widget-content[data-date='#{date}']") do
        find(".fc-button-next").click
      end
      within ".fc-widget-content[data-date='#{date}']" do
        text = find(".fc-day-content > div").text
        case arg1
          when "the"
            expect(text).not_to be_empty
          when "no"
            expect(text).to be_empty
          else
            raise
        end
      end
    end
  end
end

When(/^I specify (.*) as (start|end) date$/) do |arg1, arg2|
  @date = case arg1
            when "today"
              Date.today
            when "tomorrow"
              Date.tomorrow
            when "this date"
              (@current_inventory_pool || @inventory_pool).workday.reached_max_visits.sample
            else
              raise
          end
  step "ich setze das %s im Kalendar auf '#{I18n::l(@date)}'" % (arg2 == "start" ? _("Start Date") : _("End Date"))
end

Then(/^I receive an error message within the modal$/) do
  within ".modal #booking-calendar-errors" do
    find(".red")
  end
end

Then /^the start or end date of that line is changed$/ do
  @line.reload
  expect([@line.start_date, @line.end_date]).to include @date
end
