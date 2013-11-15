# language: de

Funktionalität: Benutzerdokumente

  Als Benutzer möchte ich meine Dokumente einsehen koennen

  Grundlage:
    Angenommen Personas existieren
    Und man ist ein Kunde mit Verträge

  @javascript
  Szenario: Schaltfläche zur Dokumentenübersichtsseite
    Wenn ich unter meinem Benutzernamen auf "Meine Dokumente" klicke
    Dann gelange ich zu der Dokumentenübersichtsseite

  @javascript  
  Szenario: Dokumentenübersicht
    Angenommen ich befinde mich auf der Dokumentenübersichtsseite
    Dann sind die Verträge nach neuestem Zeitfenster sortiert
    Und für jede Vertrag sehe ich folgende Informationen
    |Vertragsnummer|
    |Zeitfenster mit von bis Datum und Dauer|
    |Gerätepark|
    |Zweck|
    |Status|
    |Vertraglink|
    |Wertelistelink|

  @javascript
  Szenario: Rücknehmende Person
    Wenn ich einen Vertrag mit zurück gebrachten Gegenständen aus meinen Dokumenten öffne
    Dann sieht man bei den betroffenen Linien die rücknehmende Person im Format "V. Nachname"
