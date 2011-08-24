
# TODO: Refactor all these to a helper, but not sure if prawn supports helpers like that

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

# The built-in fonts in PDF readers are only guaranteed to support WinANSI encoding, therefore
# we either need to filter all text like here or supply an external font file with full
# UTF-8 support
def filter(text)
  
  unless text.nil?
     # First we discard invalid UTF-8 characters. This is so that
     # prawn doesn't throw a hissy fit.
     ic = Iconv.new('utf-8//IGNORE//TRANSLIT', 'utf-8')
     # These added bytes are to work around a bug in Iconv where
     # trailing invalid byte sequences are not removed.
     valid_text = ic.iconv(text + ' ')[0..-2]
    return valid_text
  end
end


pdf.font("Helvetica")
pdf.font_size(10)

pdf.font_size(14) do
  pdf.text filter( _("Value list") ) 
end

borrowing_party = filter( _("Borrowing party:") + "\n" + user_address )
lending_party = filter( _("Lending party:") + "\n" + lending_address )

pdf.text_box borrowing_party, 
             :width => 150,
             :height => pdf.height_of(borrowing_party),
             :overflow => :ellipses,
             :at => [pdf.bounds.left, pdf.bounds.top - 25]

pdf.text_box lending_party,
             :width => 150,
             :height => pdf.height_of(lending_party),
             :overflow => :ellipses,
             :at => [pdf.bounds.left + 160, pdf.bounds.top - 25]


pdf.move_down [pdf.height_of(borrowing_party), pdf.height_of(lending_party)].max + 10.mm

table_headers = [_("Qt"), _("Model"),  _("Value"), _("Total")]


total_value = 0
table_data = []

@order.lines.sort.each do |l|

  if l.class.to_s == "OrderLine"
    model_value = maximum_item_price(l.model) 
    line_value = model_value * l.quantity 
    total_value += line_value
  elsif l.class.to_s == "OptionLine"
    item_value = l.option.price.to_f
    model_value = model_value * l.quantity 
    total_value += line_value
  else
    model_value = 0.0
    line_value = 0.0
  end
  
  table_data << [ l.quantity, 
                  l.model.name, 
                  sprintf("%.2f", model_value),
                  sprintf("%.2f", line_value) ]
end

table_data << [ "", _("Grand total"), "", sprintf("%.2f", total_value) ]


# Table with values of the items in this order
pdf.table(table_data, 
          :column_widths  => { 0 => 15.mm, 1 => 90.mm, 2 => 20.mm, 3 => 20.mm},
          :align          => { 0 => :right, 1 => :left, 2 => :right, 3 => :right },
          :headers        => table_headers,
          :font_size      => 9,
          :padding        => 3,
          :row_colors     => ['ffffff','f1f1f1'])

pdf.move_down 10.mm

pdf.text( filter( _("This value list covers an order lasting from %s to %s." % [short_date(@order.time_window_min), short_date(@order.time_window_max)])))

pdf.move_down 10.mm

pdf.text(filter( _("All prices in %s." % LOCAL_CURRENCY_STRING)) )