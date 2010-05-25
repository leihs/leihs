
# TODO: Refactor all these to a helper, but not sure if prawn supports helpers like that


def user_address
  address = "#{filter(@contract.user.name)}"
  address += "\n#{filter(@contract.user.address)}" unless @contract.user.address.blank?
  address += "\n" unless @contract.user.zip.blank? and @contract.user.city.blank?
  address += "#{filter(@contract.user.zip)} " unless @contract.user.zip.blank?
  address += "#{filter(@contract.user.city)}" unless @contract.user.city.blank?
  address += "\n #{filter(@contract.user.country)}" unless @contract.user.country.blank?
  address += "\n #{filter(@contract.user.email)}" unless @contract.user.email.blank?
  address += "\n #{filter(@contract.user.phone)}" unless @contract.user.phone.blank?
  address += "\n #{_("Badge ID:")} #{filter(@contract.user.badge_id)}" unless @contract.user.badge_id.blank?
  return address
end

def lending_address
  # Print something like: AV-Ausleihe (AVZ)
  address = @contract.inventory_pool.name unless @contract.inventory_pool.name.blank?
  address += " (#{filter(@contract.inventory_pool.shortname)})"
  address += "\n" + CONTRACT_LENDING_PARTY_STRING
end

# The built-in fonts in PDF readers are only guaranteed to support WinANSI encoding, therefore
# we either need to filter all text like here or supply an external font file with full
# UTF-8 support
def filter(text)
  
  unless text.nil?
    # First we discard invalid UTF-8 characters. This is so that
    # prawn doesn't throw a hissy fit.
    ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
    # These added bytes are to work around a bug in Iconv where
    # trailing invalid byte sequences are not removed.
    valid_text = ic.iconv(text + ' ')[0..-2]
  
    # And now we convert to ms-ansi because it's the only character set Prawn and PDFs
    # are guaranteed to support.
    ic = Iconv.new('iso-8859-1//IGNORE//TRANSLIT','ms-ansi')
    return ic.iconv(valid_text)
  end
end


if @contract.purpose.nil?
  purpose = filter(_("No purpose given."))
else
  purpose = filter(@contract.purpose)
end


pdf.font("Helvetica")
pdf.font_size(10)


require 'barby'
require 'barby/outputter/prawn_outputter'

pdf.bounding_box [pdf.bounds.left, pdf.bounds.top_left[1]], :width => 100 do
  barcode = Barby::Code128B.new(@contract.id.to_s)
  barcode.annotate_pdf(pdf, :height => 20)
end

pdf.move_down 8.mm

pdf.font_size(14) do
  pdf.text filter(_("Contract no. %d")) % @contract.id
end

pdf.move_down 3.mm

pdf.text filter(_("This lending contract covers borrowing the following items by the person (natural or legal) described as 'borrowing party' below. Use of these items is only allowed for the purpose given below."))


borrowing_party = filter(_("Borrowing party:")) + "\n" + filter(user_address)
lending_party = filter(_("Lending party:")) + "\n" + filter(lending_address)

pdf.text_box borrowing_party, 
             :width => 150,
             :height => pdf.height_of(borrowing_party),
             :overflow => :ellipses,
             :at => [pdf.bounds.left, pdf.bounds.top - 78]

pdf.text_box lending_party,
             :width => 150,
             :height => pdf.height_of(lending_party),
             :overflow => :ellipses,
             :at => [pdf.bounds.left + 70.mm, pdf.bounds.top - 78]


pdf.move_down [pdf.height_of(borrowing_party), pdf.height_of(lending_party)].max + 15.mm


table_headers = [ filter(_("Qt")), filter(_("Inventory Code")), filter(_("Model")),  filter(_("Start date")), filter(_("End date")), filter(_("Returned date"))]


total_value = 0
mindate = @contract.lines[0].end_date

table_data = []

@contract.lines.sort.each do |l|
   
   mindate = l.end_date if ( l.end_date < mindate && l.returned_date.nil? )
   
   # Only print "broken" if the item actually is broken, otherwise a blank
   # is more than enough
   condition = ""
   if l.class.name == "ItemLine"
     condition = ("[" + _("Broken") + "] ") if l.item.is_broken? == true
   end
  
   table_data << [ l.quantity, 
                   filter(l.item.inventory_code),
                   filter(condition) + filter(l.model.name),
                   short_date(l.start_date),
                   short_date(l.end_date),
                   short_date(l.returned_date) ]
  
end

# Print the lowest item return time somewhere in a corner, just as reference
# for inventory managers
pdf.font_size(9) do
  pdf.text_box(short_date(mindate),
              :width => 20.mm,
              :height => 15.mm,
              :overflow => :ellipses,
              :at => [pdf.bounds.top_right[0] - 12.mm, pdf.bounds.top_right[1] ])
              #:at => [pdf.bounds.top - 20.mm, pdf.bounds.right + 25.mm])
end

pdf.table(table_data, 
          :column_widths  => { 0 => 10.mm, 1 => 25.mm, 2 => 70.mm, 3 => 22.mm, 4 => 22.mm, 5 => 28.mm},
          :align          => { 0 => :right, 1 => :left, 2 => :left, 3 => :left, 4 => :left, 5 => :left },
          :headers        => table_headers,
          :font_size      => 9,
          :padding        => 3,
          :row_colors     => ['ffffff','f1f1f1'])

pdf.move_down 6.mm

pdf.text filter(_("Purpose:")) + " " + filter(purpose)
pdf.move_down 3.mm

unless @contract.note.blank?
  pdf.text filter(_("Additional notes:")) + " " + @contract.note
  pdf.move_down 3.mm
end

pdf.font_size(7) do
  pdf.text filter(_("Die Benutzerin/der Benutzer ist bei unsachgemaesser Handhabung oder Verlust schadenersatzpflichtig. Sie/Er verpflichtet sich, das Material sorgfaeltig zu behandeln und gereinigt zu retournieren. Bei mangelbehafteter order verspaeteter Rueckgabe kann eine Ausleihsparre (bis zu 6 Monaten) verhaengt werden. Das geliehene Material bleibt jederzeit uneingeschraenktes Eigentum der Zuercher Hochscule der Kuenste und darf ausschliesslich fuer schulische Zwecke eingesetzt werden. Mit ihrer/seiner Unterschrift akzeptiert die Benutzerin/der Benutzer diese Bedingungen sowie die 'Richtlinie zur Ausleihe von Sachen der ZHdK und etwaige abteilungsspezifische Ausleih-Richtlinien."))
end


today = Date.today.strftime("%d.%m.%Y")

pdf.move_down 8.mm

pdf.text filter(_("Signature of borrower:")) + " " + today 

pdf.stroke do
  pdf.line_width 0.5
  pdf.horizontal_line pdf.bounds.left, 160.mm
end

pdf.move_down 8.mm

pdf.text filter(_("Signature of person taking back the item:")) 

pdf.stroke do
  pdf.line_width 0.5
  pdf.horizontal_line pdf.bounds.left, 160.mm
end
