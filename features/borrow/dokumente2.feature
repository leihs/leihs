# language: de

Funktionalität: Benutzerdokumente

  Als Benutzer möchte ich meine Dokumente einsehen koennen

  Grundlage:
    Angenommen Personas existieren
    Und man ist ein Kunde mit Verträge
  
  @javascript
  Szenario: Werteliste öffnen
    Angenommen ich befinde mich auf der Dokumentenübersichtsseite
    Und ich drücke auf den Wertelistelink
    Dann öffnet sich die Werteliste

  @javascript
  Szenario: Was ich auf der Werteliste sehen möchte
    Wenn ich eine Werteliste aus meinen Dokumenten öffne
    Dann sehe ich die Werteliste genau wie im Verwalten-Bereich

  @javascript
  Szenario: Vertrag öffnen
    Angenommen ich befinde mich auf der Dokumentenübersichtsseite
    Und ich drücke auf den Vertraglink
    Dann öffnet sich der Vertrag

  @javascript
  Szenario: Was ich auf dem Vertrag sehen möchte
    Wenn ich einen Vertrag aus meinen Dokumenten öffne
    Dann sehe ich den Vertrag genau wie im Verwalten-Bereich
