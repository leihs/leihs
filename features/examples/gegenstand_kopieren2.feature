# language: de

Funktionalität: Gegenstand kopieren

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Mike"

  @javascript
  Szenario: Bestehenden Gegenstand aus Liste kopieren
    Angenommen man befindet sich auf der Liste des Inventars
    Wenn man einen Gegenstand kopiert
    Dann wird eine neue Gegenstandskopieransicht geöffnet
    Und alle Felder bis auf Inventarcode, Seriennummer und Name wurden kopiert

  @javascript
  Szenario: Bestehenden Gegenstand aus Editieransicht kopieren
    Angenommen man befindet sich auf der Gegenstandserstellungsansicht
    Wenn man speichert und kopiert
    Dann wird eine neue Gegenstandskopieransicht geöffnet
    Und alle Felder bis auf Inventarcode, Seriennummer und Name wurden kopiert