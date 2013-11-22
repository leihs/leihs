# language: de

Funktionalität: Gegenstand bearbeiten

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Matti"

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
