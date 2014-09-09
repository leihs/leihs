# language: de

Funktionalität: Startseite

  Um einen Überblick über das ausleihbare Inventar zu erhalten
  möchte ich als Ausleiher
  einen Einstieg/Übersicht über das ausleihbare Inventar

  @personas
  Szenario: Startseite
    Angenommen ich bin Normin
    Und es existiert eine Hauptkategorie mit eigenem Bild
    Und es existiert eine Hauptkategorie ohne eigenes Bild aber mit einem Modell mit Bild
    Und man befindet sich auf der Seite der Hauptkategorien
    Dann sieht man genau die für den User bestimmte Haupt-Kategorien mit Namen
    Und man sieht für jede Kategorie ihr Bild, oder falls nicht vorhanden, das erste Bild eines Modells dieser Kategorie
    Wenn man eine Hauptkategorie auswählt
    Dann lande ich in der Modellliste für diese Hauptkategorie

  @javascript @personas
  Szenario: Haupt-Kategorien aufklappen
    Angenommen ich bin Normin
    Und man befindet sich auf der Seite der Hauptkategorien
    Wenn ich über eine Hauptkategorie mit Kindern fahre
    Dann sehe ich nur die Kinder dieser Hauptkategorie, die dem User zur Verfügung stehende Gegenstände enthalten
    Wenn ich eines dieser Kinder anwähle
    Dann lande ich in der Modellliste für diese Kategorie

  @personas
  Szenario: Kinder-Kategorien Dropdown nicht sichtbar
    Angenommen ich bin Normin
    Und man befindet sich auf der Seite der Hauptkategorien
    Und es gibt eine Hauptkategorie, derer Kinderkategorien keine dem User zur Verfügung stehende Gegenstände enthalten
    Dann hat diese Hauptkategorie keine Kinderkategorie-Dropdown
