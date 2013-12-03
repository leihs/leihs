# language: de

Funktionalität: Aushändigungen

  Als Ausleihverwalter möchte ich die Möglichkeit haben,
  Gegenstände an Kunden aushändigen zu können

  Grundlage:
    Angenommen Personas existieren

  @javascript
  Szenario: Anzeige von bereits zugewiesenen Gegenständen
    Angenommen man ist "Pius"
    Und es besteht bereits eine Aushändigung mit mindestens 21 zugewiesenen Gegenständen für einen Benutzer
    Wenn ich die Aushändigung öffne
    Dann sehe ich all die bereits zugewiesenen Gegenstände mittels Inventarcodes
