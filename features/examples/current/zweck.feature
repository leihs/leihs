# language: de

Funktionalität: Zweck

  Um den Zweck eine Bestellung oder Übergabe zu sehen
  möchte ich als Verleiher
  den vom Benutzer angegebenen Zweck sehen
  
  Grundlage:
    Gegeben sei man ist "Pius"
  
  Szenario: Unabhängigkeit
    Wenn ein Zweck gespeichert wird ist er unabhängig von einer Bestellung
     Und jeder Eintrag der Bestellung referenziert auf den Zweck
     Und jeder Eintrag eines Vertrages refereziert auf einen Zweck

  Szenario: Orte an den ich den Zweck sehe
    Wenn ich eine Bestellung genehmigen muss sehe ich den Zweck
    Wenn ich eine Aushändigung mache sehe ich auf jeder Zeile den zugewisenen Zweck 
    
  Szenario: Orte an den ich den Zweck editieren kann
    Wenn ich eine Bestellung genehmige dann kann ich den Zweck editieren.
    
  Szenario: Orte an den ich einen Zweck hinzügen kann
    Wenn ich eine Aushändigung durchführe
    Dann kann ich einen zusätzlichen Zweck hinzufügen