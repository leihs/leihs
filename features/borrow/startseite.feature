# language: de

Funktionalität: Startseite

  Um einen Überblick über das ausleihbare Inventar zu erhalten
  möchte ich als Ausleiher
  einen Einstieg/Übersicht über das ausleihbare Inventar

  @personas
  Szenario: Startseite
    Angenommen ich bin Normin
    Und man befindet sich auf der Seite der Hauptkategorien
    Dann sieht man genau die für den User bestimmte Haupt-Kategorien mit Bild und Namen
    Und das Bild entspricht dem in der Kategorie-Editieransicht hochgeladenen Bild
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
