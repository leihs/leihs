# language: de

Funktionalität: Bestellfensterchen

  Um Gegenstände ausleihen zu können
  möchte ich als Ausleiher
  die möglichkeit haben Modelle zu bestellen

  Grundlage:
    Angenommen man ist "Normin"

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
