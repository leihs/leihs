# NOTE: This needs to be written in Ruby 1.8.7 and Rails 2.x-style!
# It's used to migrate from 2.9.14 up in our migration tests.

# Inventory pool
ip = InventoryPool.create(name: 'Migration Test')
ip.shortname = 'MIG'
ip.logo_url = 'http://example.com/foo.png'
ip.default_contract_note = 'Bai bai.'
ip.email = 'from@example.com'
ip.contact_details = '+41 777 77 77'
ip.contract_description = 'Foo and bar.'
ip.description = 'This is some description'
ip.color = '#ffffff'
ip.opening_hours = 'From time to time.'
ip.save


# Models
names = ['XYZ', 'ABC', 'K777']

names.each do |name|
  m = Model.new(name: name)
  m.manufacturer = 'Someone'
  m.technical_detail = 'Something'
  m.internal_description = 'Foobar'
  m.description = "It's a thing."
  m.save
end


def random_string(length = 10)
  digits = %w(a b c d e f g h i j k l 1 2 3 4 5 6 7)
  string = ''
  while string.length < length do
    string += digits.rand
  end
  return string
end

def create_some_item(model)
  i = Item.new(model: model,
               serial_number: random_string(22),
               inventory_code: random_string(20),
               invoice_date: DateTime.now,
               owner: InventoryPool.first,
               inventory_pool: InventoryPool.first)
  i.save
  return i
end

Model.all.each do |model|
  10.times do 
    create_some_item(model)
  end
end

unless (Model.all.count > 0 and
        Item.all.count > 0 and
        InventoryPool.all.count > 0)
  puts 'Errors during data seeding.'
  exit 1
else
  puts "Data seeding created #{Model.all.count} models, #{Item.all.count} items, #{InventoryPool.all.count} inventory pools"
  exit 0
end
