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
