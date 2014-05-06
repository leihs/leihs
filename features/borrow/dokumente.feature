# language: de

Funktionalität: Benutzerdokumente

  Als Benutzer möchte ich meine Dokumente einsehen koennen

  Grundlage:
    Angenommen Personas existieren
    Und man ist ein Kunde mit Verträge

  @javascript @firefox
  Szenario: Schaltfläche zur Dokumentenübersichtsseite
    Wenn ich unter meinem Benutzernamen auf "Meine Dokumente" klicke
    Dann gelange ich zu der Dokumentenübersichtsseite

  @javascript @firefox
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

  @javascript @firefox
  Szenario: Rücknehmende Person
    Wenn ich einen Vertrag mit zurück gebrachten Gegenständen aus meinen Dokumenten öffne
    Dann sieht man bei den betroffenen Linien die rücknehmende Person im Format "V. Nachname"

  @javascript @firefox
  Szenario: Werteliste öffnen
    Angenommen ich befinde mich auf der Dokumentenübersichtsseite
    Und ich drücke auf den Wertelistelink
    Dann öffnet sich die Werteliste

  @javascript @firefox
  Szenario: Was ich auf der Werteliste sehen möchte
    Wenn ich eine Werteliste aus meinen Dokumenten öffne
    Dann sehe ich die Werteliste genau wie im Verwalten-Bereich

  @javascript @firefox
  Szenario: Vertrag öffnen
    Angenommen ich befinde mich auf der Dokumentenübersichtsseite
    Und ich drücke auf den Vertraglink
    Dann öffnet sich der Vertrag

  @javascript @firefox
  Szenario: Was ich auf dem Vertrag sehen möchte
    Wenn ich einen Vertrag aus meinen Dokumenten öffne
    Dann sehe ich den Vertrag genau wie im Verwalten-Bereich
