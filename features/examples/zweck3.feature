# language: de

Funktionalität: Zweck

  Um den Zweck einer Bestellung oder Übergabe zu sehen
  möchte ich als Verleiher
  den vom Benutzer angegebenen Zweck sehen

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Pius"

  @javascript  
  Szenario: Aushändigung ohne Zweck
    Wenn ich eine Aushändigung mache
    Und keine der ausgewählten Gegenstände hat einen Zweck angegeben
    Dann werde ich beim Aushändigen darauf hingewiesen einen Zweck anzugeben
    Und erst wenn ich einen Zweck angebebe
    Dann kann ich die Aushändigung durchführen

  @javascript  
  Szenario: Aushändigung mit Gegenständen teilweise ohne Zweck können durchgeführt werden
    Wenn ich eine Aushändigung mache
    Und einige der ausgewählten Gegenstände hat keinen Zweck angegeben
    Dann muss ich keinen Zweck angeben um die Aushändigung durchzuführen
