# language: de

Funktionalität: Software editieren

  Grundlage:
    Angenommen ich bin "Mike"

  @javascript @firefox
  Szenario: Software-Produkt editieren
    Wenn ich eine Software editiere
    Und ich ändere die folgenden Details
      | Feld | Wert |
      | Produkt | Test Software I |
      | Version | Test Version I |
      | Hersteller | Neuer Hersteller |
      | Technische Details | Installationslink beachten: http://wwww.dokuwiki.ch/neue_seite |
      | Anhänge | neuer_Anhang.tiff |
    Wenn ich speichere
    Und ich mich auf der Softwareliste befinde
    Dann die Informationen sind gespeichert
    Und die Daten wurden entsprechend aktualisiert

@upcoming
  Szenario: Modellanhänge löschen wenn Software gelöscht wird
    Angenommen es existiert eine Software mit folgenden Eigenschaften
      | in keinem Vertrag aufgeführt |
      | keiner Bestellung zugewiesen |
      | keine Lizenzen zugefügt |
      | hat Anhänge |
    Wenn ich diese Software aus der Software-Liste lösche
    Dann ist die Software gelöscht
    Und alle Anhänge sind gelöscht


  @javascript
  Szenario: Software-Lizenz editieren
    Wenn ich eine bestehende Software-Lizenz editiere
    Dann sehe ich die Informationen der "Software Details" angezeigt
    Wenn ich bestehende Links der "Software Details" anklicke
    Dann öffnet sich ein Browser mit dem entsprechenden URL
    Wenn ich eine andere Software auswähle
    Und ich eine andere Seriennummer eingebe
    Und ich einen anderen Aktivierungstyp wähle
    Und ich einen anderen Lizenztyp wähle
    Und ich den Wert "Ausleihbar" ändere
    Und ich die Optionen für das Betriebssystem ändere
    Und ich die Optionen für die Installation ändere
    Und ich das Lizenzablaufdatum ändere
    Und ich den Wert für den Maintenance-Vertrag ändere
    Und ich den Wert für Bezug ändere
    Und ich den Wert der Lizenzinformation ändere
    Und ich die Dongle-ID ändere
    Und ich den Aktivierungstyp "Mehrplatz", "Konkurrent" oder "Site-Lizenz" wähle
    Und ich eine Anzahl beim Aktivierungstyp eingebe
    #Aber ich kann die Inventarnummer nicht ändern # really? inventory manager can change the inventory number of an item right now...
    Wenn ich speichere
    Dann sind die Informationen dieser Software-Lizenz erfolgreich aktualisiert worden

  @javascript
  Szenario: Software-Lizenz editieren - Werte der Datenfelder löschen
    Wenn ich eine bestehende Software-Lizenz editiere
    Und es sind Daten für Maintenance-Ablaufdatum, Lizenzablaufdatum und Rechnungsdatum gesetzt
    Und ich das Maintenance-Ablaufdatum lösche
    Und ich das Lizenzablaufdatum lösche
    Und ich das Rechnungsdatum lösche
    Wenn ich speichere
    Dann sind die Informationen dieser Software-Lizenz erfolgreich aktualisiert
