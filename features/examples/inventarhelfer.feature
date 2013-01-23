# language: de

Funktionalität: Inventarhelfer

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Matti"

  @javascript
  Szenario: Wie man den Helferschirm erreicht
    Wenn man im Inventar Bereich ist
    Dann kann man über die Tabnavigation zum Helferschirm wechseln

  @javascript
  Szenario: Geräte über den Helferschirm editieren, mittels vollständigem Inventarcode (Scanner)
    Angenommen man ist auf dem Helferschirm
    Dann wähle Ich all die Felder über eine List oder per Namen aus
    Und ich setze all ihre Initalisierungswerte
    Dann scanne oder gebe ich den Inventarcode ein
    Dann sehe ich alle Werte des Gegenstandes in der Übersicht, die geänderten Werte sind bereits gespeichert
    Und die geänderten Werte sind hervorgehoben

  @javascript
  Szenario: Geräte über den Helferschirm editieren, mittels Inventarcode konnte nicht gefunden wurde
    Angenommen man ist auf dem Helferschirm
    Dann wähle Ich die Felder über eine List oder per Namen aus
    Und ich setze ihre Initalisierungswerte
    Dann scanne oder gebe ich den Inventarcode eines Gegenstandes ein der nicht gefunden wird
    Dann erhählt man eine Fehlermeldung

  @javascript
  Szenario: Geräte über den Helferschirm editieren mittels Inventarcode über Autovervollständigung
    Angenommen man ist auf dem Helferschirm
    Dann wähle Ich die Felder über eine List oder per Namen aus
    Und ich setze ihre Initalisierungswerte
    Dann gebe ich den Anfang des Inventarcodes eines Gegenstand ein
    Und wähle den Gegenstand über die mir vorgeschlagenen Suchtreffer
    Dann sehe ich alle Werte des Gegenstandes in der Übersicht, die geänderten Werte sind bereits gespeichert
    Und die geänderten Werte sind hervorgehoben

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
  Szenario: Werte gemäss Berechtigung speichern
    Angenommen man editiert ein Gerät über den Helferschirm
    Und man selektiert mehrere Felder
    Und man hat die Berechtigung nicht, alle Felder zu ändern
    Dann werden nur die Felder geändert, für welche der Benutzer berechtigt ist
    Und man erhält eine Fehlermeldung

  # NOTE: not yet needed
  #
  # @javascript
  # Szenario: Falsches Gerät gescanned / UNDO  
  #  Angenommen man ist auf dem Helferschirm
  #   Dann wähle Ich die Felder über eine List oder per Namen aus
  #   Und ich setze ihre Initalisierungswerte
  #   Dann scanne oder gebe ich den Inventarcode ein
  #   Dann sehe ich alle Werte des Gegenstandes in der Übersicht
  #   Und die geänderten Werte sind hervorgehoben
  #   Und diese Werte sind so gespeichert
  #   Wenn man "Widerrufen" klickt
  #   Dann werden die Änderungen widerrufen
  #   Und man sieht alle ursprünglichen Werte des Gegenstandes in der Übersicht





  






    
