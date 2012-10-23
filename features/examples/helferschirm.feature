# language: de

Funktionalität: Helferschirm

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Matti"

  @javascript
  Szenario: Wie man den Helferschirm erreicht
    Wenn man im Inventar Bereich ist
    Dann kann man über die Tabnavigation zum Helferschirm wechseln

  @javascript
  Szenario: Geräte über den Helferschirm editieren, mittels vollständigem Inventarcode (Scanner)
    Angenommen man ist auf den Helferschirm
    Dann wähle Ich die Felder über eine List oder per Namen aus
    Und ich setze ihre Initalisierungswerte
    Dann scanne oder gebe ich den Inventarcode ein
    Dann sehe ich alle Werte des Gegenstandes in der Übersicht
    Und die geänderten Werte sind hervorgehoben
    Und diese Werte sind so gespeichert

  @javascript
  Szenario: Geräte über den Helferschirm editieren, mittels Inventarcode konnte nicht gefunden wurde
    Angenommen man ist auf den Helferschirm
    Dann wähle Ich die Felder über eine List oder per Namen aus
    Und ich setze ihre Initalisierungswerte
    Dann scanne oder gebe ich den Inventarcode eines Gegenstandes ein
    Und es wurde kein Gegenstand zu diesem Inventarcode gefunden
    Dann erhählt man eine Fehlermeldung

  @javascript
  Szenario: Geräte über den Helferschirm editieren mittels Inventarcode über Autovervollständigung
    Angenommen man ist auf den Helferschirm
    Dann wähle Ich die Felder über eine List oder per Namen aus
    Und ich setze ihre Initalisierungswerte
    Dann gebe ich den Anfang des Inventarcodes eines Gegenstand ein
    Und wähle den Gegenstand über die mir vorgeschlagenen Suchtreffer
    Dann sehe ich alle Werte des Gegenstandes in der Übersicht
    Und die geänderten Werte sind hervorgehoben
    Und diese Werte sind so gespeichert

  @javascript
  Szenario: Editeren nach automatischen speichern
    Angenommen man editiert ein Gerät über den Helferschirm mittels Inventarcode
    Dann sieht man einen "Editieren" Button unter der Übersicht
    Wenn man die Editierfunktion nutzt
    Dann kann man an Ort und Stelle alle Werte des Gegenstandes editieren
    Dann klickt man "Speichern"
    Dann sind sie gespeichert
    
  @javascript
  Szenario: Editeren nach automatischen speichern abbrechen
    Angenommen man editiert ein Gerät über den Helferschirm mittels Inventarcode
    Dann sieht man einen "Editieren" Button unter der Übersicht
    Wenn man die Editierfunktion nutzt
    Dann kann man an Ort und Stelle alle Werte des Gegenstandes editieren
    Und man seine Änderungen widerrufen möchte
    Dann klickt man "Abbrechen"
    Und die Änderungen sind widerrufen
    Und man sieht alle ursprünglichen Werte des Gegenstandes in der Übersicht

  @javascript
  Szenario: Falsches Gerät gescanned / UNDO  
   Angenommen man ist auf den Helferschirm
    Dann wähle Ich die Felder über eine List oder per Namen aus
    Und ich setze ihre Initalisierungswerte
    Dann scanne oder gebe ich den Inventarcode ein
    Dann sehe ich alle Werte des Gegenstandes in der Übersicht
    Und die geänderten Werte sind hervorgehoben
    Und diese Werte sind so gespeichert
    Wenn man "Widerrufen" klickt
    Dann werden die Änderungen widerrufen
    Und man sieht alle ursprünglichen Werte des Gegenstandes in der Übersicht





  






    