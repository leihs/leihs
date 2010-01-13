
# TODO: Refactor all these to a helper, but not sure if prawn supports helpers like that


# def filter(text)
#   ic = Iconv.new('ISO-8859-15//IGNORE//TRANSLIT','utf-8')
#   ic.iconv(text)
# end


# TODO: remove filter
def user_address
  address = "#{@contract.user.name}"
  address += "\n#{@contract.user.address}" unless @contract.user.address.blank?
  address += "\n" unless @contract.user.zip.blank? and @contract.user.city.blank?
  address += "#{@contract.user.zip} " unless @contract.user.zip.blank?
  address += "#{@contract.user.city}" unless @contract.user.city.blank?
  address += "\n #{@contract.user.country}" unless @contract.user.country.blank?
  address += "\n #{@contract.user.email}" unless @contract.user.email.blank?
  address += "\n #{@contract.user.phone}" unless @contract.user.phone.blank?
  address += "\n #{_("Badge ID:")} #{@contract.user.badge_id}" unless @contract.user.badge_id.blank?
  return address
end

def lending_address
  # Print something like: AV-Ausleihe (AVZ)
  address = @contract.inventory_pool.name unless @contract.inventory_pool.name.blank?
  address += " (#{@contract.inventory_pool.shortname})"
  address += "\n" + CONTRACT_LENDING_PARTY_STRING
end


pdf.font("Helvetica")
pdf.font_size(10)

pdf.font_size(14) do
  pdf.text _("Contract no. %d") % @contract.id
end

pdf.move_down 3.mm

pdf.text(filter(_("This lending contract covers borrowing the following items by the person (natural or legal) described as 'borrowing party' below. Use of these items is only allowed for the purpose given below.")) )


borrowing_party = _("Borrowing party:") + "\n" + user_address
lending_party = _("Lending party:") + "\n" + lending_address

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


# TODO: Give table for _contract_, not value list. Print signature lines.

table_headers = [_("Qt"), _("Inventory Code"), _("Model"),  _("Start date"), _("End date"), _("Returned date")]


total_value = 0
table_data = []

@contract.lines.each do |l|
  
   table_data << [ l.quantity, 
                   l.item.inventory_code,
                   l.model.name, 
                   short_date(l.start_date),
                   short_date(l.end_date),
                   short_date(l.returned_date) ]
  
end

pdf.table(table_data, 
          :column_widths  => { 0 => 10.mm, 1 => 25.mm, 2 => 70.mm, 3 => 22.mm, 4 => 22.mm, 5 => 28.mm},
          :align          => { 0 => :right, 1 => :left, 2 => :left, 3 => :left, 4 => :left, 5 => :left },
          :headers        => table_headers,
          :font_size      => 9,
          :padding        => 3,
          :row_colors     => ['ffffff','f1f1f1'])

pdf.move_down 10.mm

