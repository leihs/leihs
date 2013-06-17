# language: de

Funktionalität: Explorative Suche

  Um Modelle anhand von Kategorien explorativ zu entdecken
  möchte ich als Ausleihender
  eine entsprehende Interaktionsmöglichkeit haben

  Grundlage:
    Angenommen persona "Normin" existing

  Szenario: Explorative Suche in Modellliste
    Angenommen man ist "Normin"
    Und man sich auf der Modellliste befindet
    Dann sehe ich die explorative Suche
    Und sie beinhaltet die direkten Kinder und deren Kinder gemäss aktuell ausgewählter Kategorie
    Und diejenigen Kategorien, die oder deren Nachfolger keine ausleihbare Gegenstände beinhalten, werden nicht angezeigt

  Szenario: Wahl einer Subkategorie
    Angenommen man ist "Normin"
    Und man sich auf der Modellliste befindet
    Wenn ich eine Kategorie wähle
    Dann werden die Modelle der aktuell angewählten Kategorie angezeigt

  Szenario: Unterstes Blatt erreicht
    Angenommen man ist "Normin"
    Und man befindet sich auf der Modellliste einer Kategorie ohne Kinder
    Dann ist die explorative Suche nicht sichtbar und die Modellliste ist erweitert