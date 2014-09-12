# language: de

Funktionalität: Bestellfensterchen

  Um Gegenstände ausleihen zu können
  möchte ich als Ausleiher
  die möglichkeit haben Modelle zu bestellen

  Grundlage:
    Angenommen ich bin Normin

  @personas
  Szenario: Bestellfensterchen
    Angenommen man befindet sich auf der Seite der Hauptkategorien
    Dann sehe ich das Bestellfensterchen

  @personas
  Szenario: Kein Bestellfensterchen
    Angenommen man befindet sich auf der Bestellübersicht
    Dann sehe ich kein Bestellfensterchen

  @personas
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

  @javascript @browser @personas
  Szenario: Bestellfensterchen aus Kalender updaten
    Wenn ich mit dem Kalender ein Modell der Bestellung hinzufüge
    Dann wird das Bestellfensterchen aktualisiert

  @javascript @personas
  Szenario: Zeit abgelaufen
    Wenn die Zeit abgelaufen ist
    Dann werde ich auf die Timeout Page weitergeleitet

  @javascript @personas
  Szenario: Zeit überschritten
    Wenn ich ein Modell der Bestellung hinzufüge
    Dann sehe ich die Zeitanzeige
    Wenn die Zeit überschritten ist

  @javascript @personas
  Szenario: Zeitentität, Ablauf der erlaubten Zeit anzeigen
    Angenommen meine Bestellung ist leer
    Wenn man befindet sich auf der Seite der Hauptkategorien
    Dann sehe ich keine Zeitanzeige
    Wenn ich ein Modell der Bestellung hinzufüge
    Dann sehe ich die Zeitanzeige
    Und die Zeitanzeige ist in einer Schaltfläche im Reiter "Bestellung" auf der rechten Seite
    Und die Zeitanzeige zählt von 30 Minuten herunter

  @personas
  Szenario: Zeit zurücksetzen
    Angenommen die Bestellung ist nicht leer
    Dann sehe ich die Zeitanzeige
    Wenn ich den Time-Out zurücksetze
    Dann wird die Zeit zurückgesetzt
