
# TODO: Refactor all these to a helper, but not sure if prawn supports helpers like that
def filter(text)
  ic = Iconv.new('ISO-8859-15//IGNORE//TRANSLIT','utf-8')
  ic.iconv(text)
end

def user_address
  address = "#{@contract.user.name}"
  address += "\n#{filter( @contract.user.address )}" unless @contract.user.address.blank?
  address += "\n" unless @contract.user.zip.blank? and @contract.user.city.blank?
  address += "#{@contract.user.zip} " unless @contract.user.zip.blank?
  address += "#{filter( @contract.user.city )}" unless @contract.user.city.blank?
  address += "\n #{filter( @contract.user.country )}" unless @contract.user.country.blank?
  address += "\n #{@contract.user.email}" unless @contract.user.email.blank?
  address += "\n #{@contract.user.phone}" unless @contract.user.phone.blank?
  address += "\n #{_("Badge ID:")} #{@contract.user.badge_id}" unless @contract.user.badge_id.blank?
  return address
end

def lending_address
  # Print something like: AV-Ausleihe (AVZ)
  address = filter(@contract.inventory_pool.name) unless @contract.inventory_pool.name.blank?
  address += " (" + filter(@contract.inventory_pool.shortname) + ")"
  address += "\n" + CONTRACT_LENDING_PARTY_STRING
end


pdf.font("Helvetica")
pdf.font_size(10)

pdf.font_size(14) do
  pdf.text filter(_("Contract no. %d")) % @contract.id
end

pdf.move_down 3.mm

pdf.text(filter(_("This lending contract covers borrowing the following items by the person (natural or legal) described as 'borrowing party' below. Use of these items is only allowed for the purpose given below.")) )


borrowing_party = _("Borrowing party:") + "\n" + (filter(user_address))
lending_party = _("Lending party:") + "\n" + (filter(lending_address))

pdf.text_box borrowing_party, 
             :width => 150,
             :height => pdf.height_of(borrowing_party),
             :overflow => :ellipses,
             :at => [pdf.bounds.left, pdf.bounds.top - 55]

pdf.text_box lending_party,
             :width => 150,
             :height => pdf.height_of(lending_party),
             :overflow => :ellipses,
             :at => [pdf.bounds.left + 70.mm, pdf.bounds.top - 55]


pdf.move_down [pdf.height_of(borrowing_party), pdf.height_of(lending_party)].max + 10.mm



# TODO: Give table for _contract_, not value list. Hook up 

table_headers = [filter(_("Qt")), filter(_("Model")),  filter(_("Value")), filter(_("Total"))]


total_value = 0
table_data = []

@contract.lines.each do |l|
  
  if l.class.to_s == "OrderLine"
    model_value = maximum_item_price(l.model) 
    line_value = model_value * l.quantity 
    total_value += line_value
  else
    model_value = 0.0
    line_value = 0.0
  end
  
  table_data << [ l.quantity, 
                  filter(l.model.name), 
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

pdf.text(_("All prices in CHF."))