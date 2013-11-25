# language: de

Funktionalität: Inventarhelfer

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Matti"

  @javascript
  Szenario: Geräte über den Helferschirm editieren, mittels Inventarcode konnte nicht gefunden wurde
    Angenommen man ist auf dem Helferschirm
    Dann wähle ich die Felder über eine List oder per Namen aus
    Und ich setze ihre Initalisierungswerte
    Dann scanne oder gebe ich den Inventarcode eines Gegenstandes ein der nicht gefunden wird
    Dann erhählt man eine Fehlermeldung

  @javascript
  Szenario: Geräte über den Helferschirm editieren mittels Inventarcode über Autovervollständigung
    Angenommen man ist auf dem Helferschirm
    Dann wähle ich die Felder über eine List oder per Namen aus
    Und ich setze ihre Initalisierungswerte
    Dann gebe ich den Anfang des Inventarcodes eines Gegenstand ein
    Und wähle den Gegenstand über die mir vorgeschlagenen Suchtreffer
    Dann sehe ich alle Werte des Gegenstandes in der Übersicht mit Modellname, die geänderten Werte sind bereits gespeichert
    Und die geänderten Werte sind hervorgehoben
