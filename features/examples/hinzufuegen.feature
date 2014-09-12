# language: de

Funktionalität: Hinzufügen von Modellen

  Grundlage:
    Angenommen ich bin Pius

  @javascript @browser @personas
  Szenario: Verfügbarkeitsanzeige beim Hinzufügen zu einer Bestellung
    Angenommen ich editiere eine Bestellung
      Und ich suche ein Modell um es hinzuzufügen
    Dann sehe ich die Verfügbarkeit innerhalb der gefundenen Modelle im Format: "2(3)/7 Modelname Typ"

  @javascript @browser @personas
  Szenario: Verfügbarkeitsanzeige beim Hinzufügen zu einer Aushändigung
    Angenommen ich mache eine Aushändigung
      Und ich suche ein Modell um es hinzuzufügen
    Dann sehe ich die Verfügbarkeit innerhalb der gefundenen Modelle im Format: "2(3)/7 Modelname Typ"