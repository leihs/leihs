# language: de

Funktionalität: Zweck

  Um den Zweck einer Bestellung oder Übergabe zu sehen
  möchte ich als Verleiher
  den vom Benutzer angegebenen Zweck sehen
  
  Grundlage:
    Angenommen Personas existieren
    Und man ist "Pius"
  
  Szenario: Unabhängigkeit
    Wenn ein Zweck gespeichert wird ist er unabhängig von einer Bestellung
     Und jeder Eintrag einer abgeschickten Bestellung referenziert auf einen Zweck
     Und jeder Eintrag eines Vertrages kann auf einen Zweck referenzieren
  
  @javascript
  Szenario: Orte, an denen ich den Zweck sehe
    Wenn ich eine Bestellung editiere
    Dann sehe ich den Zweck
    Wenn ich eine Aushändigung mache
    Dann sehe ich auf jeder Zeile den zugewisenen Zweck 
  
  @javascript
  Szenario: Orte, an denen ich den Zweck editieren kann
    Wenn ich eine Bestellung editiere
    Dann kann ich den Zweck editieren
