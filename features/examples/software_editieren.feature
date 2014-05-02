# language: de

Funktionalität: Software erfassen

  Grundlage:
    Angenommen Personas existieren
    Und ich bin "Mike"

  @javascript
  Szenario: Software-Produkt editieren
    Wenn ich eine Software editiere
    Und ich ändere die folgenden Details
      | Feld | Wert |
      | Produkt | Test Software I |
      | Version | Test Version I |
      | Hersteller | Neuer Hersteller |
      #| Betriebssystem | Mac OS |
      #| Installation | lokal |
      | Technische Details | Installationslink beachten: http://wwww.dokuwiki.ch/neue_seite |
    Wenn ich speichere
    Und ich mich auf der Softwareliste befinde
    Dann die Informationen sind gespeichert
    Und die Daten wurden entsprechend aktualisiert

  @javascript
  Szenario: Software-Lizenz editieren
    Wenn ich eine bestehende Software-Lizenz editiere
    Und ich eine andere Software auswähle
    Und ich eine andere Seriennummer eingebe
    Und ich einen anderen Aktivierungstyp wähle
    Und ich einen anderen Lizenztyp wähle
    Und ich den Wert "Ausleihbar" ändere
    #Aber ich kann die Inventarnummer nicht ändern
    Wenn ich speichere
    Dann sind die Informationen dieser Software-Lizenz erfolgreich aktualisiert worden
