require 'mein_pdf/mein_pdf'

class AusleihenController < ApplicationController

  include LoginSystem
  before_filter :herausgeber_required, :except => [ 'zeig' ]
  
  helper :pakets
  layout 'allgemein'
  
  def zeig
    @reservation = Reservation.find( params[ :id ] )
  end
  
#----------------------------------------------------------
# Schritte des Herausgabevorgangs
  
  def herausgeben
    reservation_vorbereiten
    # hier passiert nichts besonderes
  end
  
  def ident_eintragen
    reservation_vorbereiten
    @user.ausweis = params[ :user ][ :ausweis ]
    logger.debug( "I --- user vorher: #{@user.to_yaml}")
    @user.password = ''
    @user.password_confirmation = ''
    if @user.save
      Logeintrag.neuer_eintrag( session[ :user ], 'trägt Ausweis ein für',
            "#{@user.name} #{@user.ausweis}" )
      flash[ :notice ] = 'Identifikation des/r Reservierenden eingetragen'
    else
      flash[ :notice ] = 'Identifikation konnte nicht eingetragen werden!'
    end
    logger.debug( "I --- user nachher: #{@user.to_yaml}")
    redirect_to :action => 'herausgeben', :id => @reservation.id
  end
  
  def ausleihe_eintragen
    reservation_vorbereiten
    # Erst pruefen, ob der Benutzer identifiziert ist, sonst nochmals zurueck
    unless @user.ausweis and @user.ausweis.length > 0
      flash[ :alarm ] = 'Bitte den Benutzer mit Ausweisnummer identifizieren, sonst kann nicht herausgegeben werden'
      redirect_to :action => 'herausgeben', :id => @reservation.id
      
    else
      @reservation.attributes = params[ :reservation ] if params[ :reservation ]
      @reservation.status = 9  # ausgeliehen
      @reservation.startdatum = Time.now
      @reservation.herausgeber = session[ :user ]
      @reservation.updater = session[ :user ]
      
      if @reservation.save
        # Reservierung als ausgeliehen kennzeichnen
        Logeintrag.neuer_eintrag( session[ :user ], 'trägt Ausleihe ein',
              "R#{@reservation.id}" )
        session[ :direkte_herausgabe_modus ] = nil
        flash[ :notice ] = 'Reservation erfolgreich als ausgeliehen eingetragen'
        redirect_to :controller => 'ausleihen',
              :action => 'abruf_leihvertrag',
              :id => @reservation.id
      
      else
        # Reservation konnte nicht gesichert werden
        flash[ :notice ] = "Fehler beim DB Update \r #{@reservation.errors.to_yaml}"
        render :action => 'herausgeben'
      end
    end
  end
  
  def abruf_leihvertrag
    reservation_vorbereiten
    # hier passiert nichts besonderes
  end
  
  def leihvertrag
    reservation_vorbereiten
    
    if request.env['HTTP_USER_AGENT'] =~ /msie/i
      headers['Pragma'] = ''
      headers['Cache-Control'] = ''
    else
      headers['Pragma'] = 'no-cache'
      headers['Cache-Control'] = 'no-cache, must-revalidate'
    end
        
    # create pdf
    mein_pdf = MeinPDF.new()
    mein_pdf.AddPage()

    mein_pdf.SetXY(mein_pdf.GetX(), 60)
    lx = mein_pdf.GetX()
    ly = mein_pdf.GetY()
    
    # Print 'xxx ausleihvertrag'
    mein_pdf.SetStyle('logo')
    mein_pdf.SetXY(97, 15.35)
    mein_pdf.Cell(100, mein_pdf.GetLineHeight(),
          @reservation.geraetepark.name.downcase + ' ausleihvertrag', 0, 0, 'R')

    # Print 'Zürcher Hochschule ...'
    mein_pdf.SetStyle('label')
    mein_pdf.SetXY(31.85, 25.4)
    mein_pdf.Cell(50, mein_pdf.GetLineHeight(),
          @reservation.geraetepark.vertrag_bezeichnung, 0, 0, 'L')

    mein_pdf.SetXY(31.85, 41.3)
    mein_pdf.Cell(50, mein_pdf.GetLineHeight(),
          @reservation.geraetepark.vertrag_url, 0, 0, 'L')

    mein_pdf.SetXY( 148, ly )
    mein_pdf.SetStyle('title')
    mein_pdf.Cell(48, mein_pdf.GetLineHeight(),
          "zurueck bis #{@reservation.enddatum.strftime( '%d.%m.%y' )}", 0, 1, 'L')
    mein_pdf.SetXY(31.5, ly)
    mein_pdf.Cell(110, mein_pdf.GetLineHeight(),
          "Ausleihe Nr.#{@reservation.id}", 0, 1, 'L')
    # Linie unter der Überschrift
    mein_pdf.SetY(mein_pdf.GetY() + 1.5)
    mein_pdf.Line(mein_pdf.GetX() + 1, mein_pdf.GetY(), 196, mein_pdf.GetY()) 
    mein_pdf.SetY(mein_pdf.GetY() + 2.5)

    # Geraetepark Infos
    ly = mein_pdf.GetY()
    mein_pdf.SetXY( 148, ly )
    mein_pdf.SetStyle( 'label' )
    mein_pdf.MultiCell(48, mein_pdf.GetLineHeight(),
          umlaute_ersetzen( @reservation.geraetepark.ansprechpartner + "\n\n" + @reservation.geraetepark.beschreibung ), 0, 0, 'L')
    
    mein_pdf.SetXY( 31.5, ly )
    druck_label_feld( mein_pdf, 'Reservierende/r', @reservation.user.name )
    druck_label_feld( mein_pdf, 'Indentifikation', @reservation.user.ausweis )
    druck_label_feld( mein_pdf, 'Telefon', @reservation.user.telefon.to_s )
    druck_label_feld( mein_pdf, 'Abteilung', @reservation.user.abteilung )

    mein_pdf.SetY( mein_pdf.GetY() + 2.0 )
    druck_label_feld( mein_pdf, 'Leihzeitraum', @reservation.zeitraum_text )
    mein_pdf.SetY( mein_pdf.GetY() + 2.5 )

    for paket in @reservation.pakets
      druck_paket( mein_pdf, paket )
    end

    if @reservation.zubehoer
      mein_pdf.SetStyle('label')
      mein_pdf.Cell(25, mein_pdf.GetLineHeight(), 'Zubehoer', 0, 1)
      zubehoer_texte = @reservation.zubehoer.collect { |z|
            z.anzahl.to_s + ' ' + z.beschreibung }
      druck_multi_feld( mein_pdf, zubehoer_texte.join( "\n" ) )
    end
    
    # Hinweise für den Leihvertrag
    unless @reservation.hinweise.blank?
      mein_pdf.SetY( mein_pdf.GetY() + 5 )
      mein_pdf.SetStyle('label')
      mein_pdf.Cell( 165.5, mein_pdf.GetLineHeight(), 'WICHTIG', 0, 1 )
      mein_pdf.MultiCell( 165.5, mein_pdf.GetLineHeight(), umlaute_ersetzen( @reservation.hinweise ), 0, 'L' )
    end
    
    # Linie und Bedingungen
    bedingungen_text = "Die Benutzerin/der Benutzer ist bei unsachgemässer Handhabung oder Verlust schadenersatzpflichtig. Sie/Er verpflichtet sich, das Material sorgfältig zu behandeln und gereinigt zu retournieren. Bei mangelbehafteter oder verspäteter Rückgabe kann eine Ausleihsperre (bis zu 6 Monaten) verhängt werden. Das geliehene Material bleibt jederzeit uneingeschränktes Eigentum der Zürcher Hochschule der Künste. Mit ihrer/seiner Unterschrift akzeptiert die Benutzerin/der Benutzer diese Bedingungen."
    bedingungen_text = umlaute_ersetzen(bedingungen_text)
  
    mein_pdf.SetY( ( mein_pdf.GetY() + 5 > 150 ) ? mein_pdf.GetY() + 5 : 150 )
    mein_pdf.Line(mein_pdf.GetX() + 1, mein_pdf.GetY(), 196, mein_pdf.GetY()) 

    mein_pdf.SetY( mein_pdf.GetY() + 3 )
    mein_pdf.SetStyle( 'label' )
    mein_pdf.MultiCell(165.5, mein_pdf.GetLineHeight(), bedingungen_text, 0, 'L')
    
    # Unterschriften Felder
    if @reservation.herausgeber
      t_herausgeber_name = @reservation.herausgeber.name
    else
      t_herausgeber_name = session[ :user ].name
    end
    mein_pdf.SetY( mein_pdf.GetY() + 7 )
    druck_multi_feld( mein_pdf, "Unterschrift Reservierender:" )
    mein_pdf.Line(mein_pdf.GetX() + 0.5, mein_pdf.GetY(), 140, mein_pdf.GetY()) 
    mein_pdf.SetStyle( 'label' )
    mein_pdf.MultiCell(165.5, mein_pdf.GetLineHeight(),
          "Herausgegeben am #{@reservation.startdatum.strftime( "%d.%m.%y" )} von #{t_herausgeber_name}", 0, 'L')
    
    mein_pdf.SetY( mein_pdf.GetY() + 7 )
    druck_multi_feld( mein_pdf, "Unterschrift Zuruecknehmer:" )
    mein_pdf.Line(mein_pdf.GetX() + 0.5, mein_pdf.GetY(), 140, mein_pdf.GetY()) 
    mein_pdf.SetStyle( 'label' )
    mein_pdf.MultiCell(165.5, mein_pdf.GetLineHeight(),
          "Zurueckgenommen am                    von", 0, 'L')
    
    send_data( mein_pdf.Output,
          :filename => "Leihvertrag_#{@reservation.id}_#{Time.now.strftime('%y%m%d')}.pdf",
          :type => "application/pdf" )
    Logeintrag.neuer_eintrag( session[ :user ], 'generiert Leihvertrag',
          "Reservation #{@reservation.id}" )
  end
  
#----------------------------------------------------------
# Schritte einer direkten Herausgabe
  
  def direkt_heraus
    @user = User.new
    @reservation = Reservation.new
    @reservation.status = Reservation::STATUS_ZUSAMMENSTELLEN
    @reservation.startdatum = Time.now
    @reservation.enddatum = Time.now.at_midnight + 1.day
    @fruehestes_startdatum = nil
  
    session[ :direkte_herausgabe_modus ] ||= 'wahl'
  end
  
  def reservierenden_waehlen
    # nur als remote function aufrufbar
    @user = User.find( params[ :id ] )
    render :partial => 'reservierenden_waehlen'
  end
  
  def direkt_pruefen
    logger.debug( "I --- ausleihen | direkt_pruefen -- params:#{params.to_yaml}")
    session[ :direkte_herausgabe_modus ] = params[ :id ]
    
    if session[ :direkte_herausgabe_modus ] == 'wahl'
      begin
        @user = User.find( params[ :reservation ][ :user_id ] )
      rescue
        flash[ :error ] = 'Es muss ein Benutzer ausgewählt oder ein neuer angelegt werden'
        t_valid_user = false
      else
        t_valid_user = @user.valid?
      end
      
    else  # Direkter Herausgabe Modus ist wenig oder alles, d.h. neuer Benutzer
      @user = User.new( params[ :user ] )
      # fehlende Felder für einen save durch Vorgabewerte ergänzen
      @user.email = @user.vorname.downcase + '.' + @user.nachname.downcase + '@zhdk.ch' if @user.email.blank?
      @user.login = @user.email if @user.login.blank?
      t_valid_user = @user.valid_fuer_direkte_herausgabe?
      
      if t_valid_user
        # Benutzer mit Vorgabe-Rechten ausstatten, speichern
        @user.berechtigungs << Geraetepark.find_oeffentliche
        @user.berechtigungs |= [ Geraetepark.find( session[ :aktiver_geraetepark ] ) ]
        logger.debug( "I --- ausleihen --- direkt_heraus --- @reservation.user: #{@user.to_yaml}" )
        unless @user.save
          logger.debug( "-- C ausleihen | direkt pruefen -- benutzer konnte nicht gesichert werden" )
          @reservation = Reservation.new( params[ :reservation ] )
          @reservation.status = Reservation::STATUS_ZUSAMMENSTELLEN
          @reservation.startdatum = Time.now
          render :action => 'direkt_heraus' and return false
          
        else
          Logeintrag.neuer_eintrag( session[ :user ], 'erzeugt Benutzer bei direkter Herausgabe', "U#{@user.id}:#{@user.name}" )
        end
      end
    end
    
    unless t_valid_user
      logger.debug( "C --- ausleihen | direkt pruefen -- kein valider benutzer" )
      redirect_to :action => 'direkt_heraus' and return false
      
    else
      # neue Reservation anlegen
      @reservation = Reservation.new( params[ :reservation ] )
      @reservation.created_at = Time.now
      @reservation.status = Reservation::STATUS_ZUSAMMENSTELLEN
      @reservation.prioritaet = 1
      @reservation.user = @user
      @reservation.updater = session[ :user ]
      @reservation.geraetepark_id = session[ :aktiver_geraetepark ]
      t_valid_reservation = @reservation.save
  
      unless t_valid_user and t_valid_reservation
        render :action => 'direkt_heraus' and return false
        
      else
        @reservation.reload
        session[ :reservation_id ] = @reservation.id
        
        if params[ :nur_zubehoer ]
          # Direkt zum Zubehör weiter
          Logeintrag.neuer_eintrag( session[ :user ], 'beginnt direkte Herausgabe Zubehör', "für Benutzer #{@user.id}:#{@user.name}" )
          redirect_to :action => 'reservation_abschicken', :id => @reservation.id
          
        else
          # Pakete auswählen
          paketauswahl_neu
          Logeintrag.neuer_eintrag( session[ :user ], 'beginnt direkte Herausgabe', "für Benutzer #{@user.id}:#{@user.name}" )
          redirect_to :action => 'pakete_auswaehlen', :id => @reservation.id
        end
      end
    end 
  end
  
  def pakete_auswaehlen
    @t_start = Time.now
    #session[ :direkte_herausgabe_modus ] = nil
    session[ :reservieren_paketauswahl ] ||= [ ]
    session[ :paket_art_auf ] ||= Array[ Paket.find( :first, :order => 'art' ).art ]
    #logger.debug( "I --- ausleihen --- pakete_auswaehlen --- #{session.to_yaml}")
    
    @reservation = Reservation.find( params[ :id ] )
    @user = @reservation.user
    @paketauswahl = session[ :reservieren_paketauswahl ]
    @reserv_mode = true
    @pakets = Paket.find_freie_in_zeitraum(
          @reservation.startdatum,
          @reservation.enddatum,
          session[ :user ].benutzerstufe,
          session[ :aktiver_geraetepark ] )
    render :template => 'reservieren/pakete_auswaehlen'
  end
  
  def weitere_pakete
    paketauswahl_neu
    @reservation = Reservation.find( session[ :reservation_id ] )
    if @reservation.pakets.size > 0
      # Pakete aus der Reservation in die Paketauswahl schreiben
      for paket in @reservation.pakets
        session[ :reservieren_paketauswahl ] << paket.id
      end
      @reservation.pakets = [ ]
    end
    
    redirect_to :action => 'pakete_auswaehlen', :id => @reservation.id
  end
  
  def reservation_abschicken  # eigentlich herausgabe_abschicken
    # wird aufgerufen von der Paketauswahl seitlich
    # auch in der Direkten Herausgabe. Dann aber verzweigen nach Zubehoer auswählen
    @reservation = Reservation.find( session[ :reservation_id ] )
    @user = @reservation.user
    logger.debug( "C --- ausleihen | reservation abschicken -- @reservation.user: #{@user.to_yaml}")
    
    # Pakete holen und verknuepfen
    if session[ :reservieren_paketauswahl ] and session[ :reservieren_paketauswahl ].size > 0
      @pakets = Paket.find( session[ :reservieren_paketauswahl ] )
      for paket in @pakets
        @reservation.pakets |= [ paket ]
      end
      
      Logeintrag.neuer_eintrag( session[ :user ], 'stellt Reservation zusammen', "#{@reservation.pakets.size} Paket(e): #{@reservation.pakets.join( ',' )}" )
      paketauswahl_loeschen
    end
    
    # Reservation als genehmigt eintragen und zu ausleihe_eintragen weiter
    @reservation.status = 2  # genehmigt
    @reservation.save!
    render :action => 'herausgabe_abschicken'
  end
  
  def herausgabe_eintragen
    @reservation = Reservation.find( params[ :id  ] )
    @user = @reservation.user
    logger.debug( "I --- ausleihen_con | herausgabe eintragen -- @reservation.user: #{@user.to_yaml}")
    
    # Pruefe, ob user schon in der DB ist
    if @user.new_record?
      # wenn nicht, neu eintragen
      if @user.email
        @user.login = @user.email
      else
        @user.login = "direkt_#{@user.nachname}_#{@user.abteilung}"
      end
      @user.created_at = Time.now
      @user.updater = session[ :user ]
      @user.password = 'bitte8aendern'
      @user.password_confirmation = 'bitte8aendern'
      t_user_ok = @user.save
      
      @user.reload
      Logeintrag.neuer_eintrag( session[ :user ], 'trägt Benutzer bei direkter Herausgabe ein', "Benutzer #{@user.id}: #{@user.name}" )
    else
      t_user_ok = @user.valid?
    end
    logger.debug( "I --- ausleihen --- herausgabe_eintragen --- user_ok:#{t_user_ok} - @user:#{@user.to_yaml}")
    
    @user.berechtigungs |= [ @reservation.geraetepark ]
    
    @reservation.startdatum = Time.now
    @reservation.zweck = params[ :reservation ][ :zweck ]
    @reservation.prioritaet = 1
    @reservation.geraetepark_id = session[ :aktiver_geraetepark ]
    @reservation.created_at = Time.now
    @reservation.updater = session[ :user ]
    @reservation.user = @user
    t_reservation_ok = @reservation.save
    
    Logeintrag.neuer_eintrag( session[ :user ], 'trägt Reservation bei direkte Herausgabe ein', "Reservation #{@reservation.id}" )
    logger.debug( "I --- ausleihen --- herausgabe_eintragen --- reservation_ok:#{t_reservation_ok} - @reservation:#{@reservation.to_yaml}")

    if t_user_ok and t_reservation_ok
      paketauswahl_loeschen
      @reservation.reload
      redirect_to :action => 'herausgeben', :id => @reservation.id
    else
      flash[ :notice ] = 'Reservation konnte nicht in Datenbank gesichert werden'
      render :action => 'herausgabe_abschicken'
    end
  end
  
  def herausgabe_abbrechen
    if session[ :reservation_id ]
      Logeintrag.neuer_eintrag( session[ :user ], 'löscht hängende direkte Herausgabe' )
      Reservation.find( session[ :reservation_id ] ).destroy
    end
    session[ :reservation_id ] = nil
    session[ :direkte_herausgabe_modus ] = nil
    session[ :reservieren_paketauswahl ] = nil
    Logeintrag.neuer_eintrag( session[ :user ], 'bricht direkte Herausgabe ab' )
    redirect_to :controller => 'admin', :action => 'status'
  end
  
#----------------------------------------------------------
# Schritte des Rücknahmevorgangs
  
  def zuruecknehmen
    reservation_vorbereiten
    # ist die Reservation tatsächlich draussen?
    unless @reservation.ausgeliehen?
      flash[ :notice ] = 'Paket kann nicht zurückgenommen werden, weil es nicht ausgeliehen ist'
      redirect_to :controller => 'reservations',
            :action => 'show',
            :id => @reservation.id
    end
  end
  
  def ruecknahme_pruefen
    reservation_vorbereiten
    flash[ :notice ] = ''
    logger.debug( "C --- ausleihen_con | ruecknahme_pruefen -- params:#{params.to_yaml}" )
    logger.debug( "C --- ausleihen_con | ruecknahme_pruefen -- @reservation1:#{@reservation.to_yaml}" )
    
    if params[ :paket ]
      for paket_id, paket_hash in params[ :paket ]
        paket = Paket.find( paket_id )
        if paket_hash[ :zurueck ] == '1'
          paket.update_attribute( :status, paket_hash[ :status ] )  
        else
          @reservation_offen ||= @reservation.duplikat_ohne_pakete_zubehoer
          @reservation.pakets.delete( paket )
          @reservation_offen.pakets |= [ paket ]
        end
      end
    end
    
    if params[ :zubehoer ]
      logger.debug( "C --- ausleihen_con | ruecknahme_pruefen -- zubehoer!" )
      for zubehoer_id, zubehoer_hash in params[ :zubehoer ]
        logger.debug( "C --- id:#{zubehoer_id}, hash:#{zubehoer_hash}" )
        zubehoer = Zubehoer.find( zubehoer_id )
        logger.debug( "C --- zubehoer:#{zubehoer.to_yaml}" )
        unless zubehoer_hash[ :zurueck ] == '1' and zubehoer_hash[ :anzahl ].to_i >= zubehoer.anzahl
          @reservation_offen ||= @reservation.duplikat_ohne_pakete_zubehoer
          zubehoer_offen = @reservation_offen.zubehoer.create( zubehoer.attributes )
          if zubehoer_hash[ :zurueck ] == '1'
            zubehoer_offen.anzahl -= zubehoer_hash[ :anzahl ].to_i
            zubehoer.anzahl = zubehoer_hash[ :anzahl ].to_i
            zubehoer_offen.save!
            zubehoer.save!
          else
            @reservation.zubehoer.delete( zubehoer )
          end
        end
      end
    end
    
    logger.debug( "C --- ausleihen_con | ruecknahme_pruefen -- @reservation2:#{@reservation.to_yaml}" )
    logger.debug( "C --- ausleihen_con | ruecknahme_pruefen -- @reservation_offen2:#{@reservation_offen.to_yaml}" ) if @reservation_offen
    
    # ist überhaupt etwas zurückgegeben worden?
    if @reservation.pakets.blank? and @reservation.zubehoer.blank?
      # nix zurückgegeben, also Rückgabe-Res löschen
      Logeintrag.neuer_eintrag( session[ :user ], 'nimmt nichts zurück',
            "R#{@reservation.id} wird R#{@reservation_offen.id}" )
      @reservation.destroy
      @reservation = nil
      @reservation_offen.save
      flash[ :notice ] = 'Keine Rückgabe erfolgt, Ausleihe bleibt bestehen'
      
    else
      @reservation.rueckgabedatum = Time.now
      @reservation.zuruecknehmer = session[ :user ]
      @reservation.updater = session[ :user ]
      @reservation.bewertung = params[ :reservation ][ :bewertung ]
      @reservation.status = -2
      logger.debug( "C --- ausleihen_con | ruecknahme_pruefen -- reservation3:#{@reservation.to_yaml}")
    
      if @reservation.save
        Logeintrag.neuer_eintrag( session[ :user ], 'nimmt Ausleihe zurück',
              "Reservation #{@reservation.id}" )
        flash[ :notice ] += 'Ausleihe wurde zurückgebucht.'
      else
        flash[ :notice ] += 'Ausleihe konnte nicht zurückgebucht werden.'
      end
      @reservation.reload
    
      if @reservation_offen
        if @reservation_offen.save
          Logeintrag.neuer_eintrag( session[ :user ], 'trägt offene Teilausleihe ein',
                "Reservation #{@reservation_offen.id}" )
          flash[ :notice ] += ' Noch offene Teilausleihe wurde eingetragen'
        else
          flash[ :notice ] += ' Offene Teilausleihe konnte nicht eingetragen werden'
        end
        @reservation_offen.reload
      end
    end
  end
  
#---------------------------------------------------------
# Geschützte gemeinsame Methoden

  protected
  def reservation_vorbereiten
    @reservation = Reservation.find( params[ :id ] )
    if @reservation
      @user = @reservation.user
      #logger.debug( "I --- ausleihen_con -- reservation_vorbereiten -- @reservation:#{@reservation.to_yaml}" )
    else
      flash[ :notice ] = 'Reservation konnte nicht geladen werden'
      redirect_to :controller => 'admin', :action => 'status'
    end
  end

#---------------------------------------------------------
# Private Methoden für die PDF Ausgabe
  
  private
  def druck_label_feld( in_pdf, in_label, in_inhalt )
    in_pdf.SetStyle('label', 0.7)
    in_pdf.Cell(25, in_pdf.GetLineHeight(), umlaute_ersetzen( in_label ), 0, 0)
    in_pdf.SetStyle('floattext')
    in_pdf.Cell(140.5, in_pdf.GetLineHeight(), umlaute_ersetzen( in_inhalt ), 0, 1)
  end
  
  def druck_multi_feld( in_pdf, in_inhalt )
    in_pdf.SetStyle('floattext')
    in_pdf.MultiCell(165.5, in_pdf.GetLineHeight(),
          umlaute_ersetzen( in_inhalt ), 0, 'L')
    in_pdf.SetY( in_pdf.GetY() + 0.5 )
  end
  
  def druck_paket( in_pdf, in_paket )
    in_pdf.SetStyle('label')
    in_pdf.Cell(25, in_pdf.GetLineHeight(),
          umlaute_ersetzen( "Paket #{in_paket.name}" ), 0, 1)
    
    for gegenstand in in_paket.gegenstands
      in_pdf.SetStyle('floattext')
      in_pdf.Cell(25, in_pdf.GetLineHeight(),
            gegenstand.inventar_nr_text.to_s, 0, 0)
      in_pdf.Cell(85, in_pdf.GetLineHeight(),
            umlaute_ersetzen( gegenstand.modellbezeichnung ), 0, 1)
    end
    
    in_pdf.SetY( in_pdf.GetY() + 1.5 )
  end

end
