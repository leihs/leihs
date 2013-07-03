# language: de

Funktionalität: Startseite

  Um einen Überblick über das ausleihbare Inventar zu erhalten
  möchte ich als Ausleiher
  einen Einstieg/Übersicht über das ausleihbare Inventar

  Szenario: Startseite
    Angenommen man ist "Normin"
    Und man befindet sich auf der Seite der Hauptkategorien
    Dann sieht man genau die für den User bestimmte Haupt-Kategorien mit Bild und Namen
    Wenn man eine Hauptkategorie auswählt
    Dann lande ich in der Modellliste für diese Kategorie

  @javascript
  Szenario: Haupt-Kategorien aufklappen
    Angenommen man ist "Normin"
    Und man befindet sich auf der Seite der Hauptkategorien
    Wenn ich über eine Hauptkategorie mit Kindern fahre
    Dann sehe ich die Kinder dieser Hauptkategorie
    Wenn ich eines dieser Kinder anwähle
    Dann lande ich in der Modellliste für diese Kategorie
