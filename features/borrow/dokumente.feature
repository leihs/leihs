# language: de

Funktionalität: Benutzerdokumente

  Als Benutzer möchte ich meine Dokumente einsehen koennen

  Grundlage:
    Angenommen man ist ein Kunde mit Verträge

  @javascript @personas
  Szenario: Schaltfläche zur Dokumentenübersichtsseite
    Wenn ich unter meinem Benutzernamen auf "Meine Dokumente" klicke
    Dann gelange ich zu der Dokumentenübersichtsseite

  @javascript @personas
  Szenario: Dokumentenübersicht
    Angenommen ich befinde mich auf der Dokumentenübersichtsseite
    Dann sind die Verträge nach neuestem Zeitfenster sortiert
    Und für jede Vertrag sehe ich folgende Informationen
      | Vertragsnummer                          |
      | Zeitfenster mit von bis Datum und Dauer |
      | Gerätepark                              |
      | Zweck                                   |
      | Status                                  |
      | Vertraglink                             |
      | Wertelistelink                          |

  @javascript @personas
  Szenario: Rücknehmende Person
    Wenn ich einen Vertrag mit zurück gebrachten Gegenständen aus meinen Dokumenten öffne
    Dann sieht man bei den betroffenen Linien die rücknehmende Person im Format "V. Nachname"

  @javascript @personas
  Szenario: Werteliste öffnen
    Angenommen ich befinde mich auf der Dokumentenübersichtsseite
    Und ich drücke auf den Wertelistelink
    Dann öffnet sich die Werteliste

  @javascript @personas
  Szenario: Was ich auf der Werteliste sehen möchte
    Wenn ich eine Werteliste aus meinen Dokumenten öffne
    Dann sehe ich die Werteliste genau wie im Verwalten-Bereich

  @javascript @personas
  Szenario: Vertrag öffnen
    Angenommen ich befinde mich auf der Dokumentenübersichtsseite
    Und ich drücke auf den Vertraglink
    Dann öffnet sich der Vertrag

  @javascript @personas
  Szenario: Was ich auf dem Vertrag sehen möchte
    Wenn ich einen Vertrag aus meinen Dokumenten öffne
    Dann sehe ich den Vertrag genau wie im Verwalten-Bereich
