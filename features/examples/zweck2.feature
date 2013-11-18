# language: de

Funktionalität: Zweck

  Um den Zweck einer Bestellung oder Übergabe zu sehen
  möchte ich als Verleiher
  den vom Benutzer angegebenen Zweck sehen
  
  Grundlage:
    Angenommen Personas existieren
    Und man ist "Pius"
  
  @javascript  
  Szenario: Aushändigung mit Gegenständen teilweise ohne Zweck übertragen einen angegebenen Zweck nur auf die Gegenstände ohne Zweck
    Wenn ich eine Aushändigung mache
     Und einige der ausgewählten Gegenstände hat keinen Zweck angegeben
     Und ich einen Zweck angebe
    Dann wird nur den Gegenständen ohne Zweck der angegebene Zweck zugewiesen
    
  @javascript  
  Szenario: Aushändigung mit Gegenständen die alle einen Zweck haben
    Wenn ich eine Aushändigung mache
    Und alle der ausgewählten Gegenstände haben einen Zweck angegeben
    Dann kann ich keinen weiteren Zweck angeben
