# language: de

Funktionalität: Anzeige von Problemen

  Grundlage:
    Angenommen ich bin Pius
    
  @javascript @firefox
  Szenario: Problemanzeige wenn Modell nicht verfügbar bei Bestellungen
    Angenommen ich editiere eine Bestellung
     Und ein Modell ist nichtmehr verfügbar
     Dann sehe ich auf den beteiligten Linien die Auszeichnung von Problemen
     Und das Problem wird wie folgt dargestellt: "Nicht verfügbar 2(3)/7"
     Und "2" sind verfügbar für den Kunden
     Und "3" sind insgesamt verfügbar
     Und "7" sind total im Pool bekannt (ausleihbar)

  @javascript @firefox
  Szenario: Problemanzeige bei Rücknahme wenn Gegenstand defekt
    Angenommen ich mache eine Rücknahme
     Und eine Gegenstand ist defekt
     Dann sehe ich auf der Linie des betroffenen Gegenstandes die Auszeichnung von Problemen
     Und das Problem wird wie folgt dargestellt: "Gegenstand ist defekt"

  @javascript
  Szenario: Problemanzeige bei Aushändigung wenn Gegenstand defekt
    Angenommen ich mache eine Aushändigung
     Und eine Gegenstand ist defekt
     Dann sehe ich auf der Linie des betroffenen Gegenstandes die Auszeichnung von Problemen
     Und das Problem wird wie folgt dargestellt: "Gegenstand ist defekt"

  @javascript @firefox
  Szenario: Problemanzeige bei Rücknahme wenn Gegenstand unvollständig
    Angenommen ich mache eine Rücknahme
     Und eine Gegenstand ist unvollständig
     Dann sehe ich auf der Linie des betroffenen Gegenstandes die Auszeichnung von Problemen
     Und das Problem wird wie folgt dargestellt: "Gegenstand ist unvollständig"

  @javascript
  Szenario: Problemanzeige bei Aushändigung wenn Gegenstand nicht ausleihbar
    Angenommen ich mache eine Aushändigung
     Und eine Gegenstand ist nicht ausleihbar
     Dann sehe ich auf der Linie des betroffenen Gegenstandes die Auszeichnung von Problemen
     Und das Problem wird wie folgt dargestellt: "Gegenstand nicht ausleihbar"

  @javascript @firefox
  Szenario: Problemanzeige bei Rücknahme wenn Gegenstand nicht ausleihbar
    Angenommen ich mache eine Rücknahme
    Und eine Gegenstand ist nicht ausleihbar
    Dann sehe ich auf der Linie des betroffenen Gegenstandes die Auszeichnung von Problemen
    Und das Problem wird wie folgt dargestellt: "Gegenstand nicht ausleihbar"


  Szenario: Problemanzeige wenn Modell nicht verfügbar bei Aushändigung
    Angenommen ich mache eine Aushändigung
     Und eine Model ist nichtmehr verfügbar
     Dann sehe ich auf den beteiligten Linien die Auszeichnung von Problemen
     Und das Problem wird wie folgt dargestellt: "Nicht verfügbar 2(3)/7"
     Und "2" sind verfügbar für den Kunden
     Und "3" sind insgesamt verfügbar
     Und "7" sind total im Pool bekannt (ausleihbar)


  Szenario: Problemanzeige wenn Modell nicht verfügbar bei Rücknahmen
    Angenommen ich mache eine Rücknahme, die nicht überfällig ist
     Und eine Model ist nichtmehr verfügbar
     Dann sehe ich auf den beteiligten Linien die Auszeichnung von Problemen
     Und das Problem wird wie folgt dargestellt: "Nicht verfügbar 2(3)/7"
     Und "2" sind verfügbar für den Kunden
     Und "3" sind insgesamt verfügbar
     Und "7" sind total im Pool bekannt (ausleihbar)

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
