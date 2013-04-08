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
    Dann sieht man eine Fehlermeldung
    Und der Gegenstand ist noch nicht Ausgemustert