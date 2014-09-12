# language: de

Funktionalität: Kalender-Ansicht im Backend

  Grundlage:
    Angenommen ich bin Pius

  @javascript @personas
  Szenario: Verfügbare Anzahl immer anzeigen
    Wenn man den Kalender sieht
    Dann sehe ich die Verfügbarkeit von Modellen auch an Feier- und Ferientagen sowie Wochenenden

  @javascript @browser @personas
  Szenario: Anzahl im Buchungskalender während einer Bestellung überbuchen
    Angenommen ich editiere eine Bestellung
     Und ich öffne den Kalender
     Dann kann ich die Anzahl unbegrenzt erhöhen / überbuchen
     Und die Bestellung kann gespeichert werden

  @javascript @browser @personas
  Szenario: Anzahl im Buchungskalender während einer Aushändigung überbuchen
    Angenommen ich mache eine Aushändigung
     Und ich öffne den Kalender
     Dann kann ich die Anzahl unbegrenzt erhöhen / überbuchen
     Und die Aushändigung kann gespeichert werden

  @personas
  Szenario: Nicht verfügbare Zeitspannen
    Angenommen ich mache eine Aushändigung
     Und eine Model ist nichtmehr verfügbar
     Und ich editiere alle Linien
    Dann wird in der Liste unter dem Kalender die entsprechende Linie als nicht verfügbar (rot) ausgezeichnet
