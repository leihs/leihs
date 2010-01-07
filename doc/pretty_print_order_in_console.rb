# After "prettying" an order, puts your @out variable for a concatenated output

def pretty(o)
  @out ||= ""
  @out += "Order No. " + o.id.to_s + "\n"
  o.order_lines.each do |ol|
    @out += ol.quantity.to_s +  " x " + ol.model.name
    @out += " (" + ol.start_date.to_s + " to " + ol.end_date.to_s + ")"
    @out += "\n" 
    if ol.errors.size > 0
      puts o.errors + "\n"
    end
  end
  @out += "----------------------\n"
end