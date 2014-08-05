# language: de

Funktionalität: Aushändigung editieren

  Grundlage:
    Angenommen ich bin Pius

  @javascript @firefox @personas
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

  @javascript @firefox @personas
  Szenario: Systemfeedback bei Zuteilen eines Gegenstandes zur problematischen Linie
    Angenommen es gibt eine Aushändigung mit mindestens einer problematischen Linie
    Und ich die Aushändigung öffne
    Dann wird das Problemfeld für das problematische Modell angezeigt
    Wenn ich dieser Linie einen Inventarcode manuell zuweise
    Und die Zeile wird selektiert
    Dann wird die Zeile grün markiert
    Und die problematischen Auszeichnungen bleiben bei der Linie bestehen

  @personas
  Szenario: Sperrstatus des Benutzers anzeigen
    Angenommen ich eine Aushändigung mache
    Und der Benutzer für die Aushändigung ist gesperrt
    Dann sehe ich neben seinem Namen den Sperrstatus 'Gesperrt!'

  @javascript @firefox @personas
  Szenario: Systemfeedback bei Zuteilen einer Option
    Angenommen ich öffne eine Aushändigung
    Wenn ich eine Option hinzufüge
    Dann wird die Zeile selektiert
    Und die Zeile wird grün markiert
    Und ich erhalte eine Meldung

  @javascript @personas
  Szenario: Aushändigung eines bereits zugeteilten Gegenstandes
    Angenommen ich öffne eine Aushändigung mit mindestens einem zugewiesenen Gegenstand
    Wenn ich einen bereits hinzugefügten Gegenstand zuteile
    Dann erhalte ich eine entsprechende Info-Meldung 'XY ist bereits diesem Vertrag zugewiesen'
    Und die Zeile bleibt selektiert
    Und die Zeile bleibt grün markiert

  @javascript @personas
  Szenario: Standard-Vertragsnotiz
    Angenommen für den Gerätepark ist eine Standard-Vertragsnotiz konfiguriert
    Und ich öffne eine Aushändigung mit mindestens einem zugewiesenen Gegenstand
    Wenn ich die Gegenstände aushändige
    Dann erscheint ein Aushändigungsdialog
    Und diese Standard-Vertragsnotiz erscheint im Textfeld für die Vertragsnotiz

  @personas
  Szenario: Vertragsnotiz
    Wenn ich eine Aushändigung mache
    Wenn ich aushändige
    Dann erscheint ein Dialog
    Und ich kann eine Notiz für diesen Vertrag eingeben
    Wenn ich eine Notiz für diesen Vertrag eingebe
    Dann erscheint diese Notiz auf dem Vertrag

  @javascript @firefox @personas
  Szenario: Optionen mit einer Mindestmenge 1 ausgeben
    Angenommen ich öffne eine Aushändigung
    Wenn ich eine Option hinzufüge
    Und ich die Anzahl "0" in das Mengenfeld schreibe
    Dann wird die Menge mit dem ursprünglichen Wert überschrieben
    Wenn ich die Anzahl "-1" in das Mengenfeld schreibe
    Dann wird die Menge mit dem ursprünglichen Wert überschrieben
    Wenn ich die Anzahl "abc" in das Mengenfeld schreibe
    Dann wird die Menge mit dem ursprünglichen Wert überschrieben
    Wenn ich die Anzahl "2" in das Mengenfeld schreibe
    Dann wird die Menge mit dem Wert "2" gespeichert

  @javascript @firefox @personas
  Szenario: Anzeige der Seriennummer bei Zuteilung der Software-Lizenz
    Angenommen ich öffne eine Aushändigung mit einer Software
    Wenn ich in das Zuteilungsfeld links vom Software-Namen klicke
    Dann wird mir der Inventarcode sowie die vollständige Seriennummer angezeigt

  @javascript @firefox @personas
  Szenario: Listung von problematischen Gegenständen
    Angenommen es existiert ein Modell mit einem problematischen Gegenstand
    Und ich öffne eine Aushändigung für irgendeinen Benutzer
    Wenn ich diesen Modell der Aushändigung hinzufüge
    Und ich auf der Modelllinie die Gegenstandsauswahl öffne
    Dann wird der problematische Gegenstand in rot aufgelistet

  @javascript @firefox @personas
  Szenario: Keine Auflistung von ausgemusterten Gegenständen
    Angenommen es existiert ein Modell mit einem ausgemusterten und einem ausleihbaren Gegenstand
    Und ich öffne eine Aushändigung für irgendeinen Benutzer
    Wenn ich diesen Modell der Aushändigung hinzufüge
    Und ich auf der Modelllinie die Gegenstandsauswahl öffne
    Dann wird der ausgemusterte Gegenstand nicht aufgelistet

