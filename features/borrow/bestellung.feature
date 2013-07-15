# language: de

Funktionalität: Bestellung

  Um Gegenstände ausleihen zu können
  möchte ich als Ausleiher
  die möglichkeit haben Modelle zu bestellen

  Szenario: Bestellfensterchen
    Angenommen man ist "Normin"
    Und man befindet sich auf der Seite der Hauptkategorien
    Dann sehe ich das Bestellfensterchen

  Szenario: Kein Bestellfensterchen
    Angenommen man ist "Normin"
    Und man befindet sich auf der Bestellübersicht
    Dann sehe ich kein Bestellfensterchen

  Szenario: Bestellfensterchen Inhalt
    Angenommen man ist "Normin"
    Wenn ich ein Modell der Bestellung hinzufüge
    Dann erscheint es im Bestellfensterchen
    Und die Modelle sind alphabetisch sortiert
    Und gleiche Modelle werden zusammengefasst
    Wenn das gleiche Modell nochmals hinzugefügt wird
    Dann wird die Anzahl dieses Modells erhöht 
    Und ich kann zur detaillierten Bestellübersicht gelangen
    
    
