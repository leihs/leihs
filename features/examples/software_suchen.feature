# language: de

Funktionalität: Software suchen

  Grundlage:
    Angenommen ich bin Mike

  @current @personas
  Szenario: Software anhand eines Suchbegriffs finden
    Angenommen es existiert ein Software-Produkt mit folgenden Eigenschaften:
      | Produktname    | suchbegriff1 |
      | Hersteller     | suchbegriff4 |
    Und es existiert eine Software-Lizenz mit folgenden Eigenschaften:
      | Inventarnummer | suchbegriff2 |
      | Seriennummer   | suchbegriff3 |
      | Dongle-ID      | suchbegriff5 |
    Und diese Software-Lizenz ist an jemanden ausgeliehen
    Wenn ich nach einer dieser Software-Produkt Eigenschaften suche
    Dann es erscheinen alle zutreffenden Software-Produkte
    Und es erscheinen alle zutreffenden Software-Lizenzen
    Und es erscheinen alle zutreffenden Verträge, in denen diese Software-Produkt vorkommt
    Wenn ich nach einer dieser Software-Lizenz Eigenschaften suche
    Dann es erscheinen alle zutreffenden Software-Lizenzen
    Und es erscheinen alle zutreffenden Verträge, in denen diese Software-Produkt vorkommt

  @javascript @personas
  Szenario: Verträge für Software-Lizenzen anhand des Ausleihenden finden
    Angenommen es existiert eine Software-Lizenz
    Und diese Software-Lizenz ist an jemanden ausgeliehen
    Wenn ich nach dem Namen dieser Person suche
    Dann erscheint der Vertrag dieser Person in den Suchresultaten
    Und es erscheint diese Person in den Suchresultaten

  @javascript @personas
  Szenario: Aufteilung der Suchresultate
    Angenommen es existieren Software-Produkte
    Und es existieren für diese Produkte Software-Lizenzen
    Wenn ich diese in meinen Suchresultaten sehe
    Dann kann ich wählen, ausschliesslich Software-Produkte aufzulisten
    Und ich kann wählen, ausschliesslich Software-Lizenzen aufzulisten
