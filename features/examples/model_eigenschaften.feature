# language: de

Funktionalität: Modell Eigenschaften

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Mike"

  @javascript
  Szenario: Eigenschaften erstellen
  Angenommen ich erstelle ein Modell
  Wenn ich Eigenschaften hinzufügen
  Und ich die Felder mit den Platzhaltern Schlüssel und Wert angebe
  Und ich die Eigenschaften sortiere
  Und ich das Modell speichere
  Dann sind die Eigenschaften gemäss Sortierreihenfolge für dieses Modell gespeichert

  @javascript
  Szenario: Eigenschaften editieren
  Angenommen ich editiere ein Modell
  Wenn ich Eigenschaften hinzufüge
  Und ich bestehende Eigenschaften ändere
  Und ich die Eigenschaften sortiere
  Und ich das Modell speichere
  Dann sind die Eigenschaften gemäss Sortierreihenfolge für dieses Modell gespeichert

  @javascript
  Szenario: Eigenschaften löschen
  Angenommen ich editiere ein Modell
  Wenn ich eine oder mehrere bestehende Eigenschaften lösche
  Und ich das Modell speichere
  Dann sind die verbleibenden Eigenschaften gemäss Sortierreihenfolge für dieses Modell gespeichert