# language: de

Funktionalität: Gegenstand bearbeiten

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Matti"
    Und man editiert einen Gegenstand, wo man der Besitzer ist
    
  @javascript
  Szenario: Lieferanten ändern
    Angenommen man navigiert zur Gegenstandsbearbeitungsseite
    Wenn ich den Lieferanten ändere
    Und ich speichern druecke
    Dann ist bei dem bearbeiteten Gegestand der geänderte Lieferant eingetragen

  @javascript
  Szenario: Bei ausgeliehenen Gegenständen kann man die verantwortliche Abteilung nicht editieren
    Angenommen man navigiert zur Bearbeitungsseite eines Gegenstandes, der ausgeliehen ist
    Wenn ich die verantwortliche Abteilung ändere
    Und ich speichern druecke
    Dann erhält man eine Fehlermeldung, dass man diese Eigenschaft nicht editieren kann, da das Gerät ausgeliehen ist

  @javascript
  Szenario: Bei Gegenständen, die in Verträgen vorhanden sind, kann man das Modell nicht ändern
    Angenommen man navigiert zur Bearbeitungsseite eines Gegenstandes, der in einem Vertrag vorhanden ist
    Wenn ich das Modell ändere
    Und ich speichern druecke
    Dann erhält man eine Fehlermeldung, dass man diese Eigenschaft nicht editieren kann, da das Gerät in einem Vortrag vorhanden ist

  @javascript
  Szenario: Einen Gegenstand, der ausgeliehen ist, kann man nicht ausmustern
    Angenommen man navigiert zur Bearbeitungsseite eines Gegenstandes, der ausgeliehen ist
    Wenn ich den Gegenstand ausmustere
    Und ich speichern druecke
    Dann erhält man eine Fehlermeldung, dass man den Gegenstand nicht ausmustern kann, da das Gerät ausgeliehen ist