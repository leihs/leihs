# language: de

Funktionalität: Aushändigung editieren

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Pius"

  @javascript
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

  @javascript
  Szenario: Systemfeedback bei Zuteilen eines Gegenstandes zur problematischen Linie
    Angenommen es gibt eine Aushändigung mit mindestens einer problematischen Linie
    Und ich die Aushändigung öffne
    Dann wird das Problemfeld für das problematische Modell angezeigt
    Wenn ich dieser Linie einen Inventarcode manuell zuweise
    Und die Zeile wird selektiert
    Dann wird die Zeile grün markiert
    Und die problematischen Auszeichnungen bleiben bei der Linie bestehen
