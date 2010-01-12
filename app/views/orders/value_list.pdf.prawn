
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
pdf.font_size(10)

pdf.font_size(14) do
  pdf.text _("Value list")
end

pdf.text_box _("Borrowing party:") + "\n" + (filter(user_address)), 
             :width => 150,
             :overflow => :ellipses,
             :at => [pdf.bounds.left, pdf.bounds.top - 25]

pdf.text_box _("Lending party:") + "\n" + (filter(lending_address)), 
             :width => 150,
             :overflow => :ellipses,
             :at => [pdf.bounds.left + 160, pdf.bounds.top - 25]

pdf.text "Hello, World"
