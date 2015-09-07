# -*- encoding : utf-8 -*-

Given(/^I am listing visits$/) do
  visit manage_inventory_pool_visits_path @current_inventory_pool
end

Then(/^each visit shows a human-readable difference between now and its respective date$/) do
  extend ActionView::Helpers::DateHelper

  @current_inventory_pool.visits.where.not(status: :submitted).each do |v|
    find(".line[data-id='#{v.id}']").text.include?(_('%s') % time_ago_in_words(v.date))
  end
end
