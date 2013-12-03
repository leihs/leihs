# language: de

Funktionalität: Explorative Suche

  Um Modelle anhand von Kategorien explorativ zu entdecken
  möchte ich als Benutzer
  eine entsprehende Interaktionsmöglichkeit haben

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Pius"
      
  @javascript
  Szenario: Explorative Suche in der Bestellung
    Angenommen ich befinde mich in einer Bestellung
    Dann kann ich ein Modell anhand der explorativen Suche wählen
    Und die explorative Suche zeigt nur Modelle aus meinem Park an
    Und die nicht verfügbaren Modelle sind rot markiert

  @javascript
  Szenario: Explorative Suche in der Aushändigung
    Wenn ich eine Aushändigung mache
    Dann kann ich ein Modell anhand der explorativen Suche wählen
    Und die explorative Suche zeigt nur Modelle aus meinem Park an
    Und die nicht verfügbaren Modelle sind rot markiert