# language: de

Funktionalität: Software löschen

  Grundlage:
    Angenommen ich bin Mike

  @javascript @firefox @personas
  Szenario: Software-Produkt löschen
    Angenommen es existiert eine Software mit folgenden Eigenschaften
      | in keinem Vertrag aufgeführt |
      | keiner Bestellung zugewiesen |
      | keine Lizenzen zugefügt      |
    Wenn ich diese "Software" aus der Liste lösche
    Dann die Software wurde aus der Liste gelöscht
    Und die "Software" ist gelöscht

  @javascript @firefox @personas
  Szenario: Softwareanhängsel löschen wenn Software gelöscht wird
    Angenommen es existiert eine Software mit folgenden Eigenschaften
      | in keinem Vertrag aufgeführt |
      | keiner Bestellung zugewiesen |
      | keine Lizenzen zugefügt      |
      | hat Anhänge                  |
    Wenn ich diese "Software" aus der Liste lösche
    Und die "Software" ist gelöscht
    Und es wurden auch alle Anhängsel gelöscht

