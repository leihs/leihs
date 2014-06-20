# language: de

Funktionalität: Software editieren

  Grundlage:
    Angenommen ich bin Mike

  @javascript @firefox @personas
  Szenario: Software-Produkt editieren
    Wenn ich eine Software editiere
    Und ich ändere die folgenden Details
      | Feld                    | Wert                                                           |
      | Produkt                 | Test Software I                                                |
      | Version                 | Test Version I                                                 |
      | Hersteller              | Neuer Hersteller                                               |
      | Software Informationen  | Installationslink beachten: http://wwww.dokuwiki.ch/neue_seite |
    Wenn ich speichere
    Und ich mich auf der Softwareliste befinde
    Dann die Informationen sind gespeichert
    Und die Daten wurden entsprechend aktualisiert

  #73278586
  @current
  Szenario: Grösse des Software Informationen-Felds
    Angenommen eine Software mit mehr als 6 Zeilen Text im Feld "Software Informationen" existiert
    Wenn ich diese Software editiere
    Und ich in das Feld "Software-Information" klicke
    Dann wächst das Feld, bis es den ganzen Text anzeigt
    Wenn ich aus dem Feld herausgehe
    Dann schrumpft das Feld wieder auf die Ausgangsgrösse

  @current @javascript @personas
  Szenario: Software-Lizenz editieren
    Wenn ich eine bestehende Software-Lizenz mit Software-Informationen und Anhängen editiere
    Dann sehe ich die "Software Informationen" angezeigt
    Und die "Software Informationen" sind nicht editierbar
    Und die bestehende Links der "Software Informationen" öffnen beim Klicken in neuem Browser-Tab
    Dann sehe ich die "Anhänge" der Software angezeigt
    Und ich kann die Anhänge in neuem Browser-Tab öffnen
    Wenn ich eine andere Software auswähle
    Und ich eine andere Seriennummer eingebe
    Und ich einen anderen Aktivierungstyp wähle
    Und ich den Wert "Ausleihbar" ändere
    Und ich die Optionen für das Betriebssystem ändere
    Und ich die Optionen für die Installation ändere
    Und ich das Lizenzablaufdatum ändere
    Und ich den Wert für den Maintenance-Vertrag ändere
    Und ich den Wert für Bezug ändere
    Und ich den Wert der Lizenzinformation ändere
    Und ich die Dongle-ID ändere
    Und ich einen der folgenden Lizenztypen wähle:
      | Mehrplatz   |
      | Konkurrent  |
      | Site-Lizenz |
    Und ich eine Anzahl eingebe
    #Aber ich kann die Inventarnummer nicht ändern # really? inventory manager can change the inventory number of an item right now...
    Wenn ich speichere
    Dann sind die Informationen dieser Software-Lizenz erfolgreich aktualisiert worden

  @javascript @personas
  Szenario: Software-Lizenz editieren - Werte der Datenfelder löschen
    Wenn ich eine Software-Lizenz mit gesetztem Maintenance-Ablaufdatum, Lizenzablaufdatum und Rechnungsdatum editiere
    Und ich die Daten für die folgenden Feldern lösche:
      | Maintenance-Ablaufdatum |
      | Lizenzablaufdatum       |
      | Rechnungsdatum          |
    Und ich speichere
    Dann ich erhalte eine Erfolgsmeldung
    Wenn ich die gleiche Lizenz editiere
    Dann sind die folgenden Felder der Lizenz leer:
      | Maintenance-Ablaufdatum |
      | Lizenzablaufdatum       |
      | Rechnungsdatum          |
