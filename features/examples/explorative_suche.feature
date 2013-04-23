# language: de

Funktionalität: Explorative Suche

  Um Modelle anhand von Kategorien explorativ zu entdecken
  möchte ich als Benutzer
  eine entsprehende Interaktionsmöglichkeit haben

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Pius"
  
  Szenario: Explorative Suche in der Liste des Inventars
    Angenommen ich bin in der Liste des Inventars
    Und ich die Navigation der Kategorien aufklappe
    Dann sehe ich den Modellnamen gekürzt
    Wenn ich eine Kategorie anwähle
    Dann sehe ich die darunterliegenden Kategorien
    Und kann die darunterliegende Kategorie anwählen
    Und ich sehe die Hauptkategorie sowie die aktuell ausgewählte und die darunterliegenden Kategorien
    Und das Inventar wurde nach dieser Kategorie gefiltert
    Und ich kann in einem Schritt auf die aktuelle Hauptkategorie zurücknavigieren
    Und ich kann in einem Schritt auf die Übersicht der Hauptkategorien 'Übersicht' zurücknavigieren
    Wenn ich die Navigation der Kategorien wieder zuklappe
    Dann sehe ich nur noch die Liste des Inventars

  Szenario: Kategorie in der explorativen Suche suchen
    Angenommen ich bin in der Liste des Inventars
    Und die Navigation der Kategorien ist aufgeklappt
    Wenn ich nach dem Namen einer Kategorie suche
    Dann werden alle Kategorien angezeigt, welche den Namen beinhalten
    Und ich wähle eine Kategorie
    Dann sehe ich die darunterliegenden Kategorien
    Und kann die darunterliegende Kategorie anwählen
    Und ich sehe ein Suchicon mit dem Namen des gerade gesuchten Begriffs sowie die aktuell ausgewählte und die darunterliegenden Kategorien
    Und das Inventar wurde nach dieser Kategorie gefiltert

  Szenario: Zurücknavigieren in der explorativen Suche
    Angenommen ich befinde mich in der Unterkategorie der explorativen Suche
    Dann kann ich in die übergeordnete Kategorie navigieren

  Szenario: Explorative Suche in der Liste der Modelle
    Angenommen ich bin in der Liste der Modelle
    Und ich die Navigation der Kategorien aufklappe
    Dann sehe ich den Modellnamen gekürzt
    Wenn ich eine Kategorie anwähle
    Dann sehe ich die darunterliegenden Kategorien
    Und kann die darunterliegende Kategorie anwählen
    Und ich sehe die Hauptkategorie sowie die aktuell ausgewählte und die darunterliegenden Kategorien
    Und die Modelle wurden nach dieser Kategorie gefiltert    
    
  Szenario: Explorative Suche in der Bestellung
    Angenommen ich bin in einer Bestellung
    Dann kann ich ein Modell anhand der explorativen Suche wählen

  Szenario: Explorative Suche in der Aushändigung
    Angenommen ich bin in der Liste der Modelle
    Dann kann ich ein Modell anhand der explorativen Suche wählen



  




