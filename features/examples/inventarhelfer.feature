# language: de

Funktionalität: Inventarhelfer

  Grundlage:
    Angenommen ich bin Matti

  @personas
  Szenario: Wie man den Helferschirm erreicht
    Wenn man im Inventar Bereich ist
    Dann kann man über die Tabnavigation zum Helferschirm wechseln

  @javascript @personas
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

  @javascript @browser @personas
  Szenario: Bei ausgeliehenen Gegenständen kann man die verantwortliche Abteilung nicht editieren
    Angenommen man ist auf dem Helferschirm
    Und man editiert das Feld "Verantwortliche Abteilung" eines ausgeliehenen Gegenstandes, wo man Besitzer ist
    Dann erhält man eine Fehlermeldung, dass man diese Eigenschaft nicht editieren kann, da das Gerät ausgeliehen ist

  @javascript @personas
  Szenario: Die ausgeliehenen Gegenständen kann man nicht ausmustern
    Angenommen man ist auf dem Helferschirm
    Und man mustert einen ausgeliehenen Gegenstand aus
    Dann erhält man eine Fehlermeldung, dass man den Gegenstand nicht ausmustern kann, da das Gerät bereits ausgeliehen oder einer Vertragslinie zugewiesen ist

  @javascript @personas
  Szenario: Geräte über den Helferschirm editieren, mittels vollständigem Inventarcode (Scanner)
    Angenommen man ist auf dem Helferschirm
    Dann wähle ich all die Felder über eine List oder per Namen aus
    Und ich setze all ihre Initalisierungswerte
    Dann scanne oder gebe ich den Inventarcode von einem Gegenstand ein, der am Lager und in keinem Vertrag vorhanden ist
    Dann sehe ich alle Werte des Gegenstandes in der Übersicht mit Modellname, die geänderten Werte sind bereits gespeichert
    Und die geänderten Werte sind hervorgehoben

  @javascript @personas
  Szenario: Pflichtfelder
    Angenommen man ist auf dem Helferschirm
    Wenn "Bezug" ausgewählt und auf "Investition" gesetzt wird, dann muss auch "Projektnummer" angegeben werden
    Wenn "Inventarrelevant" ausgewählt und auf "Ja" gesetzt wird, dann muss auch "Anschaffungskategorie" angegeben werden
    Wenn "Ausmusterung" ausgewählt und auf "Ja" gesetzt wird, dann muss auch "Grund der Ausmusterung" angegeben werden
    Dann sind alle Pflichtfelder mit einem Stern gekenzeichnet
    Wenn ein Pflichtfeld nicht ausgefüllt/ausgewählt ist, dann lässt sich der Inventarhelfer nicht nutzen
    Und ich sehe eine Fehlermeldung
    Und die nicht ausgefüllten/ausgewählten Pflichtfelder sind rot markiert

  @javascript @personas
  Szenario: Geräte über den Helferschirm editieren, mittels Inventarcode konnte nicht gefunden wurde
    Angenommen man ist auf dem Helferschirm
    Dann wähle ich die Felder über eine List oder per Namen aus
    Und ich setze ihre Initalisierungswerte
    Dann scanne oder gebe ich den Inventarcode eines Gegenstandes ein der nicht gefunden wird
    Dann erhählt man eine Fehlermeldung

  @javascript @personas
  Szenario: Geräte über den Helferschirm editieren mittels Inventarcode über Autovervollständigung
    Angenommen man ist auf dem Helferschirm
    Dann wähle ich die Felder über eine List oder per Namen aus
    Und ich setze ihre Initalisierungswerte
    Dann gebe ich den Anfang des Inventarcodes eines Gegenstand ein
    Und wähle den Gegenstand über die mir vorgeschlagenen Suchtreffer
    Dann sehe ich alle Werte des Gegenstandes in der Übersicht mit Modellname, die geänderten Werte sind bereits gespeichert
    Und die geänderten Werte sind hervorgehoben

  @javascript @browser @personas
  Szenario: Editeren nach automatischen speichern
    Angenommen man editiert ein Gerät über den Helferschirm mittels Inventarcode
    Wenn man die Editierfunktion nutzt
    Dann kann man an Ort und Stelle alle Werte des Gegenstandes editieren
    Wenn man die Änderungen speichert
    Dann sind sie gespeichert

  @javascript @personas
  Szenario: Editeren nach automatischen speichern abbrechen
    Angenommen man editiert ein Gerät über den Helferschirm mittels Inventarcode
    Wenn man die Editierfunktion nutzt
    Dann kann man an Ort und Stelle alle Werte des Gegenstandes editieren
    Wenn man seine Änderungen widerruft
    Dann sind die Änderungen widerrufen
    Und man sieht alle ursprünglichen Werte des Gegenstandes in der Übersicht

  @javascript @personas
  Szenario: Bei Gegenständen, die in Verträgen vorhanden sind, können gewisse Felder nicht editiert werden
    Angenommen man ist auf dem Helferschirm
    Und man editiert das Feld "Modell" eines Gegenstandes, der im irgendeinen Vertrag vorhanden ist
    Dann erhält man eine Fehlermeldung, dass man diese Eigenschaft nicht editieren kann, da das Gerät in einem Vortrag vorhanden ist
