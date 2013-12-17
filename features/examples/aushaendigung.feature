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
    
    
  @javascript
  Szenario: Systemfeedback bei erfolgreicher manueller Interaktion bei Aushändigung
    Wenn ich eine Aushändigung mache
    Und einem Gegenstand einen Inventarcode manuell zuweise
    Dann wird der Gegenstand der Zeile zugeteilt
    Und die Zeile wird selektiert
    Und die Zeile wird grün markiert
    Und mir wird eine Erfolgsmeldung angezeigt
    Wenn ich die Zeile deselektiere
    Dann ist die Zeile nicht mehr grün eingefärbt
    Wenn ich den zugeteilten Gegenstand auf der Zeile entferne
    Und die Zeile ist nicht mehr markiert

  @javascript
  Szenario: Systemfeedback bei Zuteilen einer Option
    Wenn ich eine Option hinzufüge
    Dann wird die Zeile selektiert
    Und die Zeile wird grün markiert
    Und mir wird eine Erfolgsmeldung angezeigt
  
  @javascript
  Szenario: Systemfeedback bei NICHT erfolgreicher manueller Interaktion bei Aushändigung
    Wenn ich eine Aushändigung mache
    Und einem Gegenstand einen Inventarcode manuell zuweise
    Und der Gegenstand nicht verfügbar ist
    Und das Problemfeld wird angezeigt
    Und die Zeile wird selektiert
    Dann wird die Zeile GRÜN markiert
  
  @javascript
  Szenario: Aushändigung eines bereits zugeteilten Gegenstandes
    Angenommen ich befinde mich in einer Aushändigung
    Wenn ich einen bereits hinzugefügten Gegenstand zuteile
    Dann erhalte ich eine entsprechende Info-Meldung 'Sie haben diesen Gegenstand diesem Vertrag bereits zugeteilt'
    Und die Zeile bleibt selektiert
    Und die Zeile bleibt grün markiert
