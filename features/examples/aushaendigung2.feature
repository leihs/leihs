# language: de

Funktionalität: Aushändigung editieren

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
    Angenommen ich öffne eine Aushändigung
    Wenn ich eine Option hinzufüge
    Dann wird die Zeile selektiert
    Und die Zeile wird grün markiert
    Und ich erhalte eine Meldung

  @javascript
  Szenario: Aushändigung eines bereits zugeteilten Gegenstandes
    Angenommen ich öffne eine Aushändigung mit mindestens einem zugewiesenen Gegenstand
    Wenn ich einen bereits hinzugefügten Gegenstand zuteile
    Dann erhalte ich eine entsprechende Info-Meldung 'XY ist bereits diesem Vertrag zugewiesen'
    Und die Zeile bleibt selektiert
    Und die Zeile bleibt grün markiert

  Szenario: Standard-Vertragsnotiz
    Wenn ich eine Aushändigung mache
    Angenommen für den Gerätepark ist eine Standard-Vertragsnotiz konfiguriert
    Wenn ich aushändige
    Dann erscheint ein Dialog
    Und diese Standard-Vertragsnotiz erscheint im Textfeld für die Vertragsnotiz

  Szenario: Vertragsnotiz
    Wenn ich eine Aushändigung mache
    Wenn ich aushändige
    Dann erscheint ein Dialog
    Und ich kann eine Notiz für diesen Vertrag eingeben
    Wenn ich eine Notiz für diesen Vertrag eingebe
    Dann erscheint diese Notiz auf dem Vertrag
