# language: de

Funktionalität: Anzeige von Problemen

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Pius"
    
  @javascript
  Szenario: Problemanzeige wenn Modell nicht verfügbar bei Bestellungen
    Angenommen ich editiere eine Bestellung
     Und eine Model ist nichtmehr verfügbar
     Dann sehe ich auf den beteiligten Linien die Auszeichnung von Problemen
     Und das Problem wird wie folgt dargestellt: "Nicht verfügbar 2(3)/7"
     Und "2" sind verfügbar für den Kunden
     Und "3" sind insgesamt verfügbar
     Und "7" sind total im Pool bekannt (ausleihbar)
