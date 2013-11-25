# language: de

Funktionalität: Suche

  Um etwas zu finden
  möchte ich als Ausleiher
  eine Suchfunktionalität

  Szenario: Suchfeld
    Angenommen man ist "Normin"
    Und man befindet sich auf der Seite der Hauptkategorien
    Dann sieht man die Suche

  @javascript
  Szenario: Suchresultate anzeigen
    Angenommen man ist "Normin"
    Und man befindet sich auf der Seite der Hauptkategorien
    Und man gibt einen Suchbegriff ein
    Und drückt ENTER
    Dann wird die Such-Resultatseite angezeigt
    Und man sieht alle gefundenen Modelle mit Bild, Modellname und Herstellername
    Und man sieht die Sortiermöglichkeit
    Und man sieht die Geräteparkeinschränkung
    Und man sieht die Ausleihzeitraumwahl
    Und die Vorschlagswerte sind verschwunden