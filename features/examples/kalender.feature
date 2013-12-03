# language: de

Funktionalität: Kalender-Ansicht im Backend

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Pius"

  @javascript
  Szenario: Verfügbare Anzahl immer anzeigen
    Wenn man den Kalender sieht
    Dann sehe ich die Verfügbarkeit von Modellen auch an Feier- und Ferientagen sowie Wochenenden

  @javascript
  Szenario: Anzahl im Buchungskalender während einer Bestellung überbuchen
    Angenommen ich editiere eine Bestellung
     Und ich öffne den Kalender
     Dann kann ich die Anzahl unbegrenzt erhöhen / überbuchen
     Und die Bestellung kann gespeichert werden
