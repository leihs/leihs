# encoding: UTF-8
# run with "rails runner -e production PATH_TO_THIS_FILE"
# WARNING: USE AT YOUR OWN RISK!!!

require_relative('logger')
require_relative('parse_csv')
# require('pry')

csv_parser = CSVParser.new("#{File.dirname(__FILE__)}/export.csv")

csv_parser.for_each_row do |row|
  log("retiring #{row['Inventarcode']}", :info, true)
  item = Item.find_by_inventory_code(row['Inventarcode'])
  if item
    unless item.parent_id
      item.reservations.where.not(status: 'closed').destroy_all
      item.retired_reason = 'muss nicht mehr inventarisiert werden; ausgemustert durch skript'
      item.retired = Date.today
      item.save!
      csv_parser.row_success!
    else
      log("skipping #{row['Inventarcode']}, because it's part of a package", :info, true)
    end
  else
    log("could not find #{row['Inventarcode']}", :info, true)
  end
end
