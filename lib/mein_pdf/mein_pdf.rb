require 'fpdf/fpdf'
require 'fpdf/bookmark'
require 'iconv'


class MeinPDF < FPDF

  # Path properties
  @BasePath      = ''
  
  # Layout properties
  @NoBreak       = false
  @LineHeight    = 0
  @BaseLineShift = 0
  
  # Font path
  @MeinPDF_FONTPATH = './'
  
  # --------------------------------------------------------------------
  # INITIALIZATION
  # --------------------------------------------------------------------
  def initialize(orientation='P', unit='mm', format='A4')
    # Call Superclass
	super(orientation, unit, format)
    
    # Path Setup
    @BasePath = FileUtils.pwd()
    if (@BasePath.index('/public'))
      @BasePath = @BasePath.gsub(/\/public/, '')
    end
    
    # Page setup
    SetMargins(31.5, 50, 197)
    SetAutoPageBreak(true, 30) 
    SetDisplayMode('fullwidth', 'continuous')
    
    # Font Setup
    @MeinPDF_FONTPATH = @BasePath + '/lib/fonts/'
    AddFont('HelveticaNeue55Roman', '', 'HelvNR04.rb')
    AddFont('HelveticaNeue95Black', '', 'HelvNB28.rb')
    SetFont('HelveticaNeue55Roman')
    SetTextColor(0, 0, 0)
    
    # Line Setup
    SetDrawColor(0, 0, 0)
    SetLineWidth(0.2)
    
    # Bookmark Setup
    extend(PDF_Bookmark)

    
  end
    
  # --------------------------------------------------------------------
  # HEADER & FOOTER
  # --------------------------------------------------------------------
  def Header()
  
    # Save current position
    lx = GetX()
    ly = GetY()
    
    # Print 'h g k'
    SetStyle('logo')
    SetXY(11.35, 15.35)
    Cell(10, GetLineHeight(), 'h', 0, 0, 'L')
    SetXY(14.55, 15.35)
    Cell(10, GetLineHeight(), 'g', 0, 0, 'L')
    SetXY(17.85, 15.35)
    Cell(10, GetLineHeight(), 'k', 0, 0, 'L')
    
    # Print 'z'
    SetStyle('logoz')
    SetXY(39.5, 12.5)
    Cell(10, GetLineHeight(), 'Z', 0, 0, 'L')
    
		ty = 24 # Starthoehe fuer Logobeschriftung
		
		Line(31.5+1.4, 13, 31.5+3.6, 13) # Linie drueber
		Line(31.5+1.4, ty, 31.5+3.6, ty) # Linien unter Z
		if (PageNo() == 1)
  	  ty += 1.4
      # Bezeichnung des Geraeteparks
			ty += 3.2
      # Print 'Hochschule fuer Gestaltung ...'
      SetStyle('label')
      SetXY(31.85, ty)
   
      # We need to use Iconv to convert chars and umlauts
      ic = Iconv.new('iso-8859-1','utf-8')
      hochschulname = 'Hochschule für Gestaltung und Kunst Zürich'
      hochschulname = ic.iconv(hochschulname)
 
      Cell(50, GetLineHeight(), hochschulname, 0, 0, 'L')
			ty += 3.2
      SetXY(31.85, ty)
      Cell(50, GetLineHeight(), 'Mitglied zfh', 0, 0, 'L')
			ty += 4.9
      Line(31.5+1.4, ty, 31.5+3.6, ty)
			ty += 1.4
      SetXY(31.85, ty)
      Cell(50, GetLineHeight(), 'leihs.hgkz.ch', 0, 0, 'L')
			ty += 3.2
			# URL des Geraeteparks
    	ty += 4.9
    	Line(31.5+1.4, ty, 31.5+3.6, ty)
			ty += 3.2
			Line(31.5+1.4, ty, 31.5+3.6, ty)
    else
      ty += 3.2
      Line(31.5+1.4, ty, 31.5+3.6, ty)
    end
    
    # Restore last position
    SetXY(lx, ly)
  end
  
  def Footer()
    # Init font for footer
    SetStyle('label')
    
    # Draw page-number
    SetY(282)
    Cell(165.5, 0, PageNo().to_s(), 0, 0, 'L')
  end
  
  # --------------------------------------------------------------------
  # PAGE BREAKS
  # --------------------------------------------------------------------
  def AcceptPageBreak() 
    return !@NoBreak
  end
  
  def SetNoBreak(inOnOff) 
    @NoBreak = inOnOff
  end
  
  def GetLineHeight() 
    return @LineHeight
  end
  
  # --------------------------------------------------------------------
  # STYLES
  # --------------------------------------------------------------------
  def SetStyle(inStyle = 'default', inBaseLineShift = 0)
  
    if (inBaseLineShift != 0)
      SetXY(GetX(), GetY() + inBaseLineShift)
      @BaseLineShift = inBaseLineShift
    else
      if (@BaseLineShift)
        SetXY(GetX(), GetY() - @BaseLineShift)
        @BaseLineShift = 0
      end
    end
    
    case inStyle
      when 'logo'
        SetFont('HelveticaNeue55Roman', '', 16)
        @LineHeight = 8
      when 'logoz'
        SetFont('HelveticaNeue95Black', '', 24)
        @LineHeight = 12
      when 'title'
        SetFont('HelveticaNeue55Roman', '', 14)
        @LineHeight = 7
      when 'subtitle'
        SetFont('HelveticaNeue55Roman', '', 12)
        @LineHeight = 6
      when 'floattext'
        SetFont('HelveticaNeue55Roman', '', 9)
        @LineHeight = 4.5
      when 'label'
        SetFont('HelveticaNeue55Roman', '', 7)
        @LineHeight = 3.5
      else
        SetFont('HelveticaNeue55Roman', '', 9)
        @LineHeight = 4.5
    end
  end
  
	# --------------------------------------------------------------------
	# FONT METHODS
  # --------------------------------------------------------------------
  def AddFont(family, style='', file='')
    # Add a TrueType or Type1 font
    family = family.downcase
    family = 'helvetica' if family == 'arial'

    style = style.upcase
    style = 'BI' if style == 'IB'

    fontkey = family + style

    if @fonts.has_key?(fontkey)
      self.Error("Font already added: #{family} #{style}")
    end

    file = family.gsub(' ', '') + style.downcase + '.rb' if file == ''

    if @MeinPDF_FONTPATH[-1,1] == '/'
      file = @MeinPDF_FONTPATH + file
    else
      file = @MeinPDF_FONTPATH + '/' + file
    end

    load file

    if FontDef.desc.nil?
      self.Error("Could not include font definition file #{file}")
    end

    i = @fonts.length + 1

    @fonts[fontkey] = {'i'    => i, 
                       'type' => FontDef.type,
                       'name' => FontDef.name,
                       'desc' => FontDef.desc,
                       'up' => FontDef.up,
                       'ut' => FontDef.ut,
                       'cw' => FontDef.cw,
                       'enc' => FontDef.enc,
                       'file' => FontDef.file }

    if FontDef.diff
      # Search existing encodings
      unless @diffs.include?(FontDef.diff)
        @diffs.push(FontDef.diff)
        @fonts[fontkey]['diff'] = @diffs.length - 1
      end
    end

    if FontDef.file
      if FontDef.type == 'TrueType'
        @FontFiles[FontDef.file] = {'length1' => FontDef.originalsize}
      else
        @FontFiles[FontDef.file] = {'length1' => FontDef.size1, 'length2' => FontDef.size2}
      end
    end
    return self
  end

  def putfonts
    nf=@n
    @diffs.each do |diff|
      # Encodings
      newobj
      out('<</Type /Encoding /BaseEncoding /WinAnsiEncoding /Differences ' + '['+diff+']>>')
      out('endobj')
    end

    @FontFiles.each do |file, info|
      # Font file embedding
      newobj
      @FontFiles[file]['n'] = @n
        if @MeinPDF_FONTPATH[-1,1] == '/' then
          file = @MeinPDF_FONTPATH + file
        else
          file = @MeinPDF_FONTPATH + '/' + file
        end

        size = File.size(file)
        unless File.exists?(file)
          Error('Font file not found')
        end
        
        out('<</Length ' + size.to_s)

        if file[-2, 2] == '.z' then
          out('/Filter /FlateDecode')
        end
        out('/Length1 ' + info['length1'])
        out('/Length2 ' + info['length2'] + ' /Length3 0') if info['length2']
        out('>>')
        
        font = 0
        File.open(file, 'rb') do |f|
          font = f.read
        end
        
        putstream(font)
        out('endobj')
      end

      file = 0
      @fonts.each do |k, font|
        # Font objects
        @fonts[k]['n']=@n+1
        type=font['type']
        name=font['name']
        if type=='core'
          # Standard font
          newobj
          out('<</Type /Font')
          out('/BaseFont /'+name)
          out('/Subtype /Type1')
          if name!='Symbol' and name!='ZapfDingbats'
            out('/Encoding /WinAnsiEncoding')
          end
          out('>>')
          out('endobj')
        elsif type=='Type1' or type=='TrueType'
          # Additional Type1 or TrueType font
          newobj
          out('<</Type /Font')
          out('/BaseFont /'+name)
          out('/Subtype /'+type)
          out('/FirstChar 32 /LastChar 255')
          out('/Widths '+(@n+1).to_s+' 0 R')
          out('/FontDescriptor '+(@n+2).to_s+' 0 R')
          if font['enc'] and font['enc'] != ''
            unless font['diff'].nil?
              out('/Encoding '+(nf+font['diff'])+' 0 R')
            else
              out('/Encoding /WinAnsiEncoding')
            end
          end
          out('>>')
          out('endobj')
          # Widths
          newobj
          cw=font['cw']
          s='['
          32.upto(255) do |i|
            s << cw[i].to_s+' '
          end
          out(s+']')
          out('endobj')
          # Descriptor
          newobj
          s='<</Type /FontDescriptor /FontName /'+name
          font['desc'].each do |k, v|
            s << ' /'+k+' '+v
          end
          file=font['file']
          if file
            s << ' /FontFile'+(type=='Type1' ? '' : '2')+' '+@FontFiles[file]['n'].to_s+' 0 R'
          end
          out(s+'>>')
          out('endobj')
        else
          # Allow for additional types
          mtd='put'+type.downcase
          unless self.respond_to?(mtd)
            self.Error('Unsupported font type: '+type)
        end
        self.send(mtd, font)
      end
    end
  end

end
