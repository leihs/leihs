module Export
  def self.csv_string(header, objects)
    require 'csv'

    CSV.generate(col_sep: ';',
                 quote_char: "\"",
                 force_quotes: true,
                 headers: :first_row) do |csv|
      csv << header
      objects.each do |object|
        csv << header.map { |h| object[h] }
      end
    end
  end

  def self.excel_string(header, objects, worksheet_name: '')
    p = Axlsx::Package.new
    ### stuff needed for proper display of line breaks inside of cells ###
    p.use_shared_strings = true
    wrap = p.workbook.styles.add_style alignment: { wrap_text: true }
    ######################################################################
    wb = p.workbook
    wb.add_worksheet(name: worksheet_name) do |sheet|
      sheet.add_row header
      objects.each do |object|
        sheet.add_row header.map { |h| object[h] }, style: wrap
      end
    end
    p.to_stream.read
  end
end
