# language: de

Funktionalität: Gegenstand ausmustern

  Grundlage:
    Angenommen Personas existieren
    
  @javascript
  Szenario: Gegenstand ausmustern
    Angenommen man ist "Matti"
    Und man sucht nach einem nicht ausgeliehenen Gegenstand
    Dann kann man diesen Gegenstand mit Angabe des Grundes erfolgreich ausmustern
    Und der gerade ausgemusterte Gegenstand verschwindet sofort aus der Inventarliste

  @javascript
  Szenario: Verhinderung von Ausmusterung eines ausgeliehenen Gegenstandes
    Angenommen man ist "Mike"
    Und man sucht nach einem ausgeliehenen Gegenstand
    Dann hat man keine Möglichkeit übers Interface solchen Gegenstand auszumustern

  @javascript
  Szenario: Verhinderung von Ausmusterung eines Gegenstandes bei dem ich nicht als Besitzer eingetragen bin
    Angenommen man ist "Matti"
    Und man sucht nach einem Gegenstand bei dem ich nicht als Besitzer eingetragen bin
    Dann hat man keine Möglichkeit übers Interface solchen Gegenstand auszumustern

  @javascript
  Szenario: Fehlermeldung bei der Ausmusterung ohne angabe eines Grundes
    Angenommen man ist "Matti"
    Und man sucht nach einem nicht ausgeliehenen Gegenstand
    Und man gibt bei der Ausmusterung keinen Grund an
    Dann sehe ich eine Fehlermeldung
    Und der Gegenstand ist noch nicht Ausgemustert

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
