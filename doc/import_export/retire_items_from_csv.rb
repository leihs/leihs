# encoding: utf-8
# This is to be run from the Rails console using require:
# rails c
# require 'doc/other/csv_import_of_items'

import_file = '/tmp/ausmustern.csv'

@failures = 0
@successes = 0

@errorlog = File.open('/tmp/import_errors.txt', 'w+')

items_to_import = CSV.open(import_file, col_sep: "\t", headers: true)

def log_error(error, item)
  @errorlog.puts "ERROR: #{error}. --- Item: #{item}"
end

items_to_import.each do |item|
  ic = item['Inventarnummer']
  i = Item.where(inventory_code: ic).first
  if i
    i.retired = true
    i.retired_reason = item['Notiz']
    if i.save
      @successes += 1
    else
      @failures += 1
      log_error("Could not retire item #{i.inventory_code}. Errors: #{i.errors.full_messages}", ic)
    end
  else
    log_error("Item with inventory code #{ic} not found", ic)
  end
  #i.note = item["Note"]

end

puts '-----------------------------------------'
puts 'DONE'
puts "#{@successes} successes, #{@failures} failures"
puts '-----------------------------------------'


@errorlog.close
