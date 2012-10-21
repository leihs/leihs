# language: de

Funktionalität: Gegenstand bearbeiten

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Matti"
    
  @javascript
  Szenario: Pflichtfelder
    Angenommen man editiert einen Gegenstand
    Dann muss der "Bezug" unter "Rechnungsinformationen" ausgewählt werden
    Wenn "Investition" bei "Bezug" ausgewählt ist muss auch "Projektnummer" angegeben werden
    Wenn "Ausgemustert" bei "Ausmusterung" ausgewählt ist muss auch "Grund der Ausmusterung" angegeben werden
    Dann sind alle Pflichtfelder mit einem Stern gekenzeichnet
    Wenn ein Pflichtfeld nicht ausgefüllt/ausgewählt ist, dann lässt sich der Gegenstand nicht speichern 
    Und der Benutzer sieht eine Fehlermeldung
    Und die nicht ausgefüllten/ausgewählten Pflichtfelder sind rot markiert