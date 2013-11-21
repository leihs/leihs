# language: de

Funktionalität: Inventarhelfer

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Matti"

  # FIXME this scenario is currently executed as first, otherwise it fails.
  @javascript
  Szenario: Geräte über den Helferschirm editieren, mittels vollständigem Inventarcode (Scanner)
    Angenommen man ist auf dem Helferschirm
    Dann wähle ich all die Felder über eine List oder per Namen aus
    Und ich setze all ihre Initalisierungswerte
    Dann scanne oder gebe ich den Inventarcode von einem Gegenstand ein, der am Lager und in keinem Vertrag vorhanden ist
    Dann sehe ich alle Werte des Gegenstandes in der Übersicht mit Modellname, die geänderten Werte sind bereits gespeichert
    Und die geänderten Werte sind hervorgehoben
    
  @javascript
  Szenario: Pflichtfelder
    Angenommen man ist auf dem Helferschirm
    Wenn "Bezug" ausgewählt und auf "Investition" gesetzt wird, dann muss auch "Projektnummer" angegeben werden
    Wenn "Inventarrelevant" ausgewählt und auf "Ja" gesetzt wird, dann muss auch "Anschaffungskategorie" angegeben werden
    Wenn "Ausmusterung" ausgewählt und auf "Ja" gesetzt wird, dann muss auch "Grund der Ausmusterung" angegeben werden
    Dann sind alle Pflichtfelder mit einem Stern gekenzeichnet
    Wenn ein Pflichtfeld nicht ausgefüllt/ausgewählt ist, dann lässt sich der Inventarhelfer nicht nutzen
    Und der Benutzer sieht eine Fehlermeldung
    Und die nicht ausgefüllten/ausgewählten Pflichtfelder sind rot markiert
