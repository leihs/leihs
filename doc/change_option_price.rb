

def set_price(option_id, price)
  begin 
    o = Option.find(option_id)
    o.price = price
    if o.save
      puts "Option #{option_id} (#{o.name}) saved with price #{price}"
    end
  rescue ActiveRecord::RecordNotFound
    puts "Option with ID #{option_id} not found."
  end
end


require 'faster_csv'
options = FasterCSV.open("/tmp/option_prices.csv")
options.each do |o|
  set_price(o[0], o[1])
end
