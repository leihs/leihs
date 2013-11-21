# language: de

Funktionalität: Kalender-Ansicht im Backend

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Pius"

  @javascript
  Szenario: Anzahl im Buchungskalender während einer Aushändigung überbuchen
    Angenommen ich mache eine Aushändigung
     Und ich öffne den Kalender
     Dann kann ich die Anzahl unbegrenzt erhöhen / überbuchen
     Und die Aushändigung kann gespeichert werden

  @javascript
  Szenario: Nicht verfügbare Zeitspannen
    Angenommen ich mache eine Aushändigung
     Und eine Model ist nichtmehr verfügbar
     Und ich editiere alle Linien
    Dann wird in der Liste unter dem Kalender die entsprechende Linie als nicht verfügbar (rot) ausgezeichnet
