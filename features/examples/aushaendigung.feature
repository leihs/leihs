# language: de

Funktionalität: Aushaendigung editieren

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Pius"
    Und ich öffne eine Aushaendigung
  
  @javascript
  Szenario: Sperrstatus des Benutzers anzeigen
    Angenommen der Benutzer ist gesperrt
    Dann sehe ich neben seinem Namen den Sperrstatus 'Gesperrt!'
