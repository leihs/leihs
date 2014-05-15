# language: de

Funktionalität: Aushändigung editieren

  Grundlage:
    Angenommen ich bin Pius

  @javascript @firefox
  Szenario: Systemfeedback bei erfolgreicher manueller Interaktion bei Aushändigung
    Angenommen es gibt eine Aushändigung mit mindestens einem nicht problematischen Modell
    Und ich die Aushändigung öffne
    Wenn ich dem nicht problematischen Modell einen Inventarcode zuweise
    Dann wird der Gegenstand der Zeile zugeteilt
    Und die Zeile wird selektiert
    Und die Zeile wird grün markiert
    Und ich erhalte eine Erfolgsmeldung
    Wenn ich die Zeile deselektiere
    Dann ist die Zeile nicht mehr grün eingefärbt
    Wenn ich die Zeile wieder selektiere
    Dann wird die Zeile grün markiert
    Wenn ich den zugeteilten Gegenstand auf der Zeile entferne
    Dann ist die Zeile nicht mehr grün markiert

  @javascript @firefox
  Szenario: Systemfeedback bei Zuteilen eines Gegenstandes zur problematischen Linie
    Angenommen es gibt eine Aushändigung mit mindestens einer problematischen Linie
    Und ich die Aushändigung öffne
    Dann wird das Problemfeld für das problematische Modell angezeigt
    Wenn ich dieser Linie einen Inventarcode manuell zuweise
    Und die Zeile wird selektiert
    Dann wird die Zeile grün markiert
    Und die problematischen Auszeichnungen bleiben bei der Linie bestehen


  Szenario: Sperrstatus des Benutzers anzeigen
    Angenommen ich eine Aushändigung mache
    Und der Benutzer für die Aushändigung ist gesperrt
    Dann sehe ich neben seinem Namen den Sperrstatus 'Gesperrt!'

  @javascript @firefox
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

  @javascript
  Szenario: Standard-Vertragsnotiz
    Angenommen für den Gerätepark ist eine Standard-Vertragsnotiz konfiguriert
    Und ich öffne eine Aushändigung mit mindestens einem zugewiesenen Gegenstand
    Wenn ich die Gegenstände aushändige
    Dann erscheint ein Aushändigungsdialog
    Und diese Standard-Vertragsnotiz erscheint im Textfeld für die Vertragsnotiz

  Szenario: Vertragsnotiz
    Wenn ich eine Aushändigung mache
    Wenn ich aushändige
    Dann erscheint ein Dialog
    Und ich kann eine Notiz für diesen Vertrag eingeben
    Wenn ich eine Notiz für diesen Vertrag eingebe
    Dann erscheint diese Notiz auf dem Vertrag

  Szenario: Raum und Gestell in Aushändigung anzeigen
    Angenommen ich öffne eine Aushändigung
    Wenn ich ein Modell hinzufüge
    Dann wird auf dieser hinzugefügten Linie der Raum sowie das Gestell des ersten, verfügbaren Gegenstandes angezeigt

  Szenario: Optionen mit einer Midestmenge 1 ausgeben
    Angenommen ich öffne eine Aushändigung mit einer Option
    Wenn ich die Anzahl "0" in das Mengenfeld schreibe
    Dann wird die Menge "0" mit dem Wert "1" überschrieben

    