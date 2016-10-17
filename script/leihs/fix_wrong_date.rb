# encoding: UTF-8
# run with "rails runner -e production PATH_TO_THIS_FILE"
# WARNING: USE AT YOUR OWN RISK!!!

require_relative('logger')
require_relative('parse_csv')
# require('pry')

csv_parser = CSVParser.new("#{File.dirname(__FILE__)}/export.csv")

csv_parser.for_each_row do |row|
  ic = row['Inventarcode']
  log("updating #{ic}", :info, true)
  item = Item.find_by_inventory_code(ic)
  if item
    item.invoice_date = item.created_at
    item.last_check = item.created_at
    item.save!
    csv_parser.row_success!
  else
    log("could not find #{ic}", :info, true)
  end
end
