# encoding: utf-8
Then(/^I can export all inventory to a CSV file$/) do
  find('.dropdown-toggle', text: "#{_('Export')} #{_('Inventory')}").click
  find('#csv-export')
end

Then(/^I can export all inventory to an Excel file$/) do
  find('.dropdown-toggle', text: "#{_('Export')} #{_('Inventory')}").click
  find('#excel-export')
end
