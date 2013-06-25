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
  Szenario: Liste gemäss Suchkritieren anzeigen
    Angenommen man ist "Normin"
    Und man befindet sich auf der Seite der Hauptkategorien
    Wenn man einen Suchbegriff eingibt
    Dann sieht man das Foto, den Namen und den Hersteller der ersten 6 Modelle gemäss aktuellem Suchbegriff
    Und sieht den Link 'Alle Suchresultate anzeigen'
 
  @javascript
  Szenario: Vorschlag wählen
    Angenommen man ist "Normin"
    Und man befindet sich auf der Seite der Hauptkategorien
    Und man wählt ein Modell von der Vorschlagsliste der Suche
    Dann wird die Modell-Ansichtsseite geöffnet
    
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