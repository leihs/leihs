# language: de

Funktionalität: Bestellung editieren

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Pius"

  @javascript
  Szenario: Sperrstatus des Benutzers anzeigen
    Angenommen ich öffne eine Bestellung von ein gesperrter Benutzer
    Dann sehe ich neben seinem Namen den Sperrstatus 'Gesperrt!'
