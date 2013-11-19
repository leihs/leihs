# language: de

Funktionalität: Anzeige von Problemen

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Pius"
      
  @javascript
  Szenario: Problemanzeige bei Aushändigung wenn Gegenstand nicht ausleihbar
    Angenommen ich mache eine Aushändigung
     Und eine Gegenstand ist nicht ausleihbar
     Dann sehe ich auf der Linie des betroffenen Gegenstandes die Auszeichnung von Problemen
     Und das Problem wird wie folgt dargestellt: "Gegenstand nicht ausleihbar"

  @javascript
  Szenario: Problemanzeige bei Rücknahme wenn Gegenstand nicht ausleihbar
    Angenommen ich mache eine Rücknahme
    Und eine Gegenstand ist nicht ausleihbar
    Dann sehe ich auf der Linie des betroffenen Gegenstandes die Auszeichnung von Problemen
    Und das Problem wird wie folgt dargestellt: "Gegenstand nicht ausleihbar"
