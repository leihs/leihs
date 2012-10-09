# language: de

Funktionalität: Gegenstand bearbeiten

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Matti"
    
  @javascript
  Szenario: Pflichtfelder
    Angenommen man editiert einen Gegenstand
    Dann muss der "Bezug" unter "Rechnungsinformationene" ausgewählt werden
    Wenn "Investition" bei "Bezug" ausgewählt ist muss auch eine Projektnummer angegeben werden
    Wenn "ausgemustert" unter "Zustand" ausgewählt wird muss auch ein Grund angegegeben werden
    Dann sind alle Pflichtfelder mit einem Stern gekenzeichnet
    Wenn ein Pflichtfeld nicht ausgefüllt/ausgewählt ist, dann lässt sich der Gegenstand nicht speichern 
    Und der Benutzer sieht eine Fehlermeldung "Bitte Pflichtfelder ausfüllen" 
    Und die nicht ausgefüllten/ausgewählten Pflichtfelder sind rot markiert