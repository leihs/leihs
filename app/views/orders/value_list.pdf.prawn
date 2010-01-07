
def filter(text)
  ic = Iconv.new('iso-8859-1//IGNORE//TRANSLIT','utf-8')
  ic.iconv(text)
end

def user_address
  @order.user.name
end

def lending_address
  CONTRACT_LENDING_PARTY_STRING      
end

def maximum_item_price(model)
  maximum = 0
  model.items.each do |i|
    maximum = i.price.to_f if i.price.to_f > maximum
  end
  return maximum
end


pdf.font("Helvetica")

pdf.bounding_box [4, 2], :width => 90 do
  pdf.text _("Borrowing party:")
  #pdf.move_down 10
  pdf.text(filter(user_address))
end

pdf.bounding_box [8, 2], :width => 90 do
  pdf.text _("Lending party:")
  #pdf.move_down 10
  pdf.text(filter(lending_address))
end

