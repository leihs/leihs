# language: de

Funktionalität: Gegenstand ausmustern

  Grundlage:
    Angenommen Personas existieren
    
  @javascript
  Szenario: Ausmusterung rückgangig machen
    Angenommen man ist "Mike"
    Und man sucht nach einem ausgemusterten Gegenstand, wo man der Besitzer ist
    Und man befindet sich auf der Gegenstandseditierseite dieses Gegenstands
    Wenn man die Ausmusterung bei diesem Gegenstand zurück setzt
    Und die Anschaffungskategorie ist ausgewählt
    Und ich speichere
    Dann wurde man auf die Inventarliste geleitet
    Und dieses Gegenstand ist nicht mehr ausgemustert

  @javascript
  Szenario: Gegenstandsansichtseite von einem ausgemusterten Gegenstand für Verantwortlichen anzeigen
    Angenommen man ist "Mike"
    Und man sucht nach einem ausgemusterten Gegenstand, wo man der Verantwortliche und nicht der Besitzer ist
    Dann man befindet sich auf der Gegenstandseditierseite dieses Gegenstands
