# language: de

Funktionalität: Gegenstand bearbeiten

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Matti"

  @javascript
  Szenario: Lieferanten ändern
    Angenommen man editiert einen Gegenstand, wo man der Besitzer ist
    Wenn ich den Lieferanten ändere
    Und ich speichern druecke
    Dann ist bei dem bearbeiteten Gegestand der geänderte Lieferant eingetragen

  @javascript
  Szenario: Bei ausgeliehenen Gegenständen kann man die verantwortliche Abteilung nicht editieren
    Angenommen man navigiert zur Bearbeitungsseite eines Gegenstandes, der ausgeliehen ist
    Wenn ich die verantwortliche Abteilung ändere
    Und ich speichern druecke
    Dann erhält man eine Fehlermeldung, dass man diese Eigenschaft nicht editieren kann, da das Gerät ausgeliehen ist
