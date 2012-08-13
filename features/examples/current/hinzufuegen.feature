# language: de

Funktionalität: Hinzufügen von Modellen

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Pius"
    
  @javascript
  Szenario: Verfügbarkeitsanzeige beim Hinzufügen
    Angenommen ich editiere eine Bestellung oder mache eine Aushändigung
      Und ich suche ein Modell um es hinzuzufügen
    Dann sehe ich die Verfügbarkeit innerhalb der gefundenen Modelle im Format: "2(3)/7 Modelname Typ"
     Und "2" sind verfügbar für den Kunden
     Und "3" sind insgesamt verfügbar
     Und "7" sind total im Pool bekannt (ausleihbar)