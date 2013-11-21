# language: de

Funktionalität: Inventarhelfer

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Matti"

  Szenario: Wie man den Helferschirm erreicht
    Wenn man im Inventar Bereich ist
    Dann kann man über die Tabnavigation zum Helferschirm wechseln

  @javascript
  Szenario: Gestell bei vorhandenem Ort ändern
    Angenommen man ist auf dem Helferschirm
    Und es existiert ein Gegenstand, welches sich denselben Ort mit einem anderen Gegenstand teilt
    Dann wähle ich das Feld "Gestell" aus der Liste aus
    Und ich setze den Wert für das Feld "Gestell"
    Dann gebe ich den Anfang des Inventarcodes des spezifischen Gegenstandes ein
    Und wähle den Gegenstand über die mir vorgeschlagenen Suchtreffer
    Dann sehe ich alle Werte des Gegenstandes in der Übersicht mit Modellname, die geänderten Werte sind bereits gespeichert
    Und die geänderten Werte sind hervorgehoben
    Und der Ort des anderen Gegenstandes ist dergleiche geblieben

  @javascript
  Szenario: Bei ausgeliehenen Gegenständen kann man die verantwortliche Abteilung nicht editieren
    Angenommen man ist auf dem Helferschirm
    Und man editiert das Feld "Verantwortliche Abteilung" eines ausgeliehenen Gegenstandes
    Dann erhält man eine Fehlermeldung, dass man diese Eigenschaft nicht editieren kann, da das Gerät ausgeliehen ist

  @javascript
  Szenario: Die ausgeliehenen Gegenständen kann man nicht ausmustern
    Angenommen man ist auf dem Helferschirm
    Und man mustert einen ausgeliehenen Gegenstand aus
    Dann erhält man eine Fehlermeldung, dass man den Gegenstand nicht ausmustern kann, da das Gerät ausgeliehen ist

