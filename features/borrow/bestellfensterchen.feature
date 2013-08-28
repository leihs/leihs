# language: de

Funktionalität: Bestellung

  Um Gegenstände ausleihen zu können
  möchte ich als Ausleiher
  die möglichkeit haben Modelle zu bestellen

  Grundlage:
    Angenommen man ist "Normin"

  Szenario: Bestellfensterchen
    Angenommen man befindet sich auf der Seite der Hauptkategorien
    Dann sehe ich das Bestellfensterchen

  Szenario: Kein Bestellfensterchen
    Angenommen man befindet sich auf der Bestellübersicht
    Dann sehe ich kein Bestellfensterchen

  Szenario: Bestellfensterchen Inhalt
    Angenommen ich ein Modell der Bestellung hinzufüge
    Dann erscheint es im Bestellfensterchen
    Und die Modelle im Bestellfensterchen sind alphabetisch sortiert
    Und gleiche Modelle werden zusammengefasst
    Wenn das gleiche Modell nochmals hinzugefügt wird
    Dann wird die Anzahl dieses Modells erhöht
    Und die Modelle im Bestellfensterchen sind alphabetisch sortiert
    Und gleiche Modelle werden zusammengefasst
    Und ich kann zur detaillierten Bestellübersicht gelangen

  @javascript
  Szenario: Bestellfensterchen aus Kalender updaten
    Wenn ich mit dem Kalender ein Modell der Bestellung hinzufüge
    Dann wird das Bestellfensterchen aktualisiert
 
  @javascript
  Szenario: Zeitentität, Ablauf der erlaubten Zeit anzeigen
    Angenommen meine Bestellung ist leer
    Wenn man befindet sich auf der Seite der Hauptkategorien
    Dann sehe ich keine Zeitanzeige
    Wenn ich ein Modell der Bestellung hinzufüge
    Dann sehe ich die Zeitanzeige
    Und die Zeitanzeige ist in einer Schaltfläche im Reiter "Bestellung" auf der rechten Seite
    Und die Zeitanzeige zählt von 30 Minuten herunter
    
  @javascript
  Szenario: Zeit zurücksetzen
    Angenommen die Bestellung ist nicht leer
    Dann sehe ich die Zeitanzeige
    Wenn ich den Time-Out zurücksetze
    Dann wird die Zeit zurückgesetzt
    
  @javascript
  Szenario: Zeit abgelaufen
    Wenn die Zeit abgelaufen ist
    Dann werde ich auf die Timeout Page weitergeleitet

  @javascript
  Szenario: Zeit überschritten
    Wenn die Zeit überschritten ist
    Dann werde ich auf die Timeout Page weitergeleitet
