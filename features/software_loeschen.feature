# language: de

Funktionalität: Software löschen

  Grundlage:
    Angenommen ich bin "Mike"

  @javascript
  Szenario: Software-Produkt löschen
    Angenommen es existiert ein Software-Produkt mit folgenden Eigenschaften
      | in keinem Vertrag aufgeführt |
      | keiner Bestellung zugewiesen |
      | keine Software-Lizenz zugefügt |
    Wenn ich dieses Software-Produkt aus der Liste lösche
    Dann das Software-Produkt wurde aus der Liste gelöscht
    Und das Software-Produkt ist gelöscht

