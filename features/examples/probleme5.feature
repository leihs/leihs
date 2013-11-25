# language: de

Funktionalität: Anzeige von Problemen

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Pius"

  @javascript
  Szenario: Problemanzeige bei Aushändigung wenn Gegenstand unvollständig
    Angenommen ich mache eine Aushändigung
     Und eine Gegenstand ist unvollständig
     Dann sehe ich auf der Linie des betroffenen Gegenstandes die Auszeichnung von Problemen
     Und das Problem wird wie folgt dargestellt: "Gegenstand ist unvollständig"

  @javascript
  Szenario: Problemanzeige bei Rücknahme wenn verspätet
    Angenommen ich mache eine Rücknahme eines verspäteten Gegenstandes
     Dann sehe ich auf der Linie des betroffenen Gegenstandes die Auszeichnung von Problemen
     Und das Problem wird wie folgt dargestellt: "Überfällig seit 6 Tagen"
