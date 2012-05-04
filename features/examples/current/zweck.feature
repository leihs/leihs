# language: de

Funktionalität: Zweck

  Um den Zweck eine Bestellung oder Übergabe zu sehen
  möchte ich als Verleiher
  den vom Benutzer angegebenen Zweck sehen
  
  Grundlage:
    Angenommen man ist "Pius"
  
  Szenario: Unabhängigkeit
    Wenn ein Zweck gespeichert wird ist er unabhängig von einer Bestellung
     Und jeder Eintrag einer Bestellung referenziert einen Zweck
     Und jeder Eintrag eines Vertrages referenziert auf einen Zweck

  Szenario: Orte, an denen ich den Zweck sehe
    Wenn ich eine Bestellung genehmigen muss 
    Dann sehe ich den Zweck
    Wenn ich eine Aushändigung mache
    Dann sehe ich auf jeder Zeile den zugewisenen Zweck 
    
  Szenario: Orte, an denen ich den Zweck editieren kann
    Wenn ich eine Bestellung genehmige
    Dann kann ich den Zweck editieren.
    
  Szenario: Orte, an denen ich einen Zweck hinzügen kann
    Wenn ich eine Aushändigung durchführe
    Dann kann ich einen zusätzlichen Zweck hinzufügen
