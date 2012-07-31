# language: de

Funktionalität: Anzeige von Problemen

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Pius"
    
  @javascript
  Szenario: Problemanzeige wenn Modell nicht verfügbar
    Angenommen ich editiere eine Bestellung, mache eine Rücknahme oder eine Aushändigung
     Und eine Model ist nichtmehr verfügbar
     Dann sehe ich auf den beteiligten Linien die Auszeichnung von Problemen
     Und das Problem wird wie folgt dargestellt: "Nicht verfügbar 2(3)/7"
     Und "2" sind verfügbar für den Kunden
     Und "3" sind insgesamt verfügbar
     Und "7" sind total im Pool bekannt (ausleihbar)

  @javascript
  Szenario: Problemanzeige wenn Gegenstand nicht ausleihbar
    Angenommen ich mache eine Rücknahme oder eine Aushändigung
     Und eine Gegenstand ist nicht ausleihbar
     Dann sehe ich auf der Linie des betroffenen Gegenstandes die Auszeichnung von Problemen
     Und das Problem wird wie folgt dargestellt: "Gegenstand nicht ausleihbar"

  @javascript
  Szenario: Problemanzeige wenn Gegenstand defekt
    Angenommen ich mache eine Rücknahme oder eine Aushändigung
     Und eine Gegenstand ist defekt
     Dann sehe ich auf der Linie des betroffenen Gegenstandes die Auszeichnung von Problemen
     Und das Problem wird wie folgt dargestellt: "Gegenstand ist defekt"

  @javascript
  Szenario: Problemanzeige wenn Gegenstand unvollständig
    Angenommen ich mache eine Rücknahme oder eine Aushändigung
     Und eine Gegenstand ist unvollständig
     Dann sehe ich auf der Linie des betroffenen Gegenstandes die Auszeichnung von Problemen
     Und das Problem wird wie folgt dargestellt: "Gegenstand ist unvollständig"

  
