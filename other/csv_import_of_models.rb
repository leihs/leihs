
require 'faster_csv'

import_file = "/tmp/theater.csv"

def create_model(name, category1, category2)

  m = Model.find_by_name(name)
  if m.nil?
    c1 = Category.find_or_create_by_name(category1) unless category1.blank?
    c2 = Category.find_or_create_by_name(category2) unless category2.blank?

    m = Model.create(:name => name)
    m.categories << c1 unless c1.blank?
    m.categories << c2 unless c2.blank?
    m.save
  end

  return m
end

items_to_import = FasterCSV.open(import_file, :headers => false)

items_to_import.each do |item|
  create_model(item[0], item[1], item[2])
end
