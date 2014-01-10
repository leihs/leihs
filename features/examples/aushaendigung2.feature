# language: de

Funktionalität: Aushaendigung editieren

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Pius"

  @javascript
  Szenario: Sperrstatus des Benutzers anzeigen
    Angenommen ich eine Aushändigung mache
    Und der Benutzer für die Aushändigung ist gesperrt
    Dann sehe ich neben seinem Namen den Sperrstatus 'Gesperrt!'

  @javascript
  Szenario: Systemfeedback bei Zuteilen einer Option
    Angenommen ich öffne eine Aushaendigung
    Wenn ich eine Option hinzufüge
    Dann wird die Zeile selektiert
    Und die Zeile wird grün markiert
    Und mir wird eine Erfolgsmeldung angezeigt

  @javascript
  Szenario: Aushändigung eines bereits zugeteilten Gegenstandes
    Angenommen ich öffne eine Aushaendigung mit mindestens einem zugewiesenen Gegenstand
    Wenn ich einen bereits hinzugefügten Gegenstand zuteile
    Dann erhalte ich eine entsprechende Info-Meldung 'XY ist bereits diesem Vertrag zugewiesen'
    Und die Zeile bleibt selektiert
    Und die Zeile bleibt grün markiert
