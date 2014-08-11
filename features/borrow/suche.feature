# language: de

Funktionalität: Suche

  Um etwas zu finden möchte ich als Ausleiher eine Suchfunktionalität

  Grundlage:
    Angenommen ich bin Normin

  @personas
  Szenario: Suchfeld
    Angenommen man befindet sich auf der Seite der Hauptkategorien
    Dann sieht man die Suche

  @javascript @personas
  Szenario: Liste gemäss Suchkritieren anzeigen
    Angenommen man befindet sich auf der Seite der Hauptkategorien
    Wenn man einen Suchbegriff eingibt
    Dann sieht man das Foto, den Namen und den Hersteller der ersten 6 Modelle gemäss aktuellem Suchbegriff
    Und sieht den Link 'Alle Suchresultate anzeigen'

  @javascript @personas
  Szenario: Man findet nur Modelle die man auch ausleihen kann
    Angenommen ich nach einem Modell suche, welches in nicht ausleihen kann
    Dann wird dieses Modell auch nicht in den Suchergebnissen angezeigt

  @javascript @personas
  Szenario: Vorschlag wählen
    Angenommen man befindet sich auf der Seite der Hauptkategorien
    Und man wählt ein Modell von der Vorschlagsliste der Suche
    Dann wird die Modell-Ansichtsseite geöffnet

  @personas
  Szenario: Suchfeld
    Angenommen man befindet sich auf der Seite der Hauptkategorien
    Dann sieht man die Suche

  @javascript @personas
  Szenario: Suchresultate anzeigen
    Angenommen man befindet sich auf der Seite der Hauptkategorien
    Und man gibt einen Suchbegriff ein
    Und drückt ENTER
    Dann wird die Such-Resultatseite angezeigt
    Und man sieht alle gefundenen Modelle mit Bild, Modellname und Herstellername
    Und man sieht die Sortiermöglichkeit
    Und man sieht die Geräteparkeinschränkung
    Und man sieht die Ausleihzeitraumwahl
    Und die Vorschlagswerte sind verschwunden

  @javascript @personas
  Szenario: Suchbegriff mit Leerschlag anzeigen
    Angenommen man befindet sich auf der Seite der Hauptkategorien
    Wenn ich einen Suchbegriff bestehend aus mindestens zwei Wörtern und einem Leerschlage eigebe
    Und drückt ENTER
    Dann wird die Such-Resultatseite angezeigt
    Und man sieht alle gefundenen Modelle mit Bild, Modellname und Herstellername

