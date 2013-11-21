# language: de

Funktionalität: Inventarhelfer

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Matti"

  @javascript
  Szenario: Editeren nach automatischen speichern
    Angenommen man editiert ein Gerät über den Helferschirm mittels Inventarcode
    Wenn man die Editierfunktion nutzt
    Dann kann man an Ort und Stelle alle Werte des Gegenstandes editieren
    Wenn man die Änderungen speichert
    Dann sind sie gespeichert
    
  @javascript
  Szenario: Editeren nach automatischen speichern abbrechen
    Angenommen man editiert ein Gerät über den Helferschirm mittels Inventarcode
    Wenn man die Editierfunktion nutzt
    Dann kann man an Ort und Stelle alle Werte des Gegenstandes editieren
    Wenn man seine Änderungen widerruft
    Dann sind die Änderungen widerrufen
    Und man sieht alle ursprünglichen Werte des Gegenstandes in der Übersicht

  @javascript
  Szenario: Bei Gegenständen, die in Verträgen vorhanden sind, können gewisse Felder nicht editiert werden
    Angenommen man ist auf dem Helferschirm
    Und man editiert das Feld "Modell" eines Gegenstandes, der im irgendeinen Vertrag vorhanden ist
    Dann erhält man eine Fehlermeldung, dass man diese Eigenschaft nicht editieren kann, da das Gerät in einem Vortrag vorhanden ist
