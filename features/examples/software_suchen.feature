# language: de

Funktionalität: Software suchen

  Grundlage:
    Angenommen ich bin "Mike"

  Szenario: Software anhand eines Suchbegriffs finden
    Angenommen es existiert eine Software mit den folgenden Eigenschaften:
    |Produktname|suchbegriff1|
    |Lizenznummer|suchbegriff2|
    |Hersteller             |suchbegriff4                     |
    Wenn ich nach einer dieser Eigenschaften suche
    Dann erscheinen alle zutreffenden Software-Produkte
    Und es erscehinen alle zutreffenden Software-Lizenzen
    Und es erscheinen alle zutreffenden  Verträge, in denen diese Software vorkommt

  Szenario: Verträge für Software-Lizenzen anhand des Ausleihenden finden
    Angenommen es existiert eine Software-Lizenz
    Und diese Software-Lizenz ist an jemanden ausgeliehen
    Wenn ich nach dem Namen dieser Person suche
    Dann erscheint der Vertrag dieser Person in den Suchresultaten
    Und es erscheint diese Person in den Suchresultaten

  Szenario: Aufteilung der Suchresultate
    Angenommen es existieren Software-Produkte
    Und es existieren für diese Produkte Software-Lizenzen
    Wenn ich diese in meinen Suchresultaten sehe
    Dann kann ich wählen, ausschliesslich Software-Produkte aufzulisten
    Und ich kann wählen, ausschliesslich Software-Lizenzen aufzulisten