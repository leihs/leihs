# language: de

Funktionalität: Software erfassen

  Grundlage:
    Angenommen Personas existieren
    Und ich bin "Mike"

  @javascript
  Szenario: Software-Produkt erfassen
    Wenn ich eine neue Software hinzufüge
    Und ich erfasse die folgenden Details
      | Feld                               | Wert                       |
      | Produkt                            | Test Software              |
      | Version                            | Test Version               |
      | Hersteller                         | Test Hersteller            |
      #| Betriebssystem                     | Windows                    |
      #| Installation                       | Citrix                     |
      | Hinweise                           | Installationslink beachten: http://wwww.dokuwiki.ch    |
    Wenn ich speichere
    Dann ist die neue Software erstellt und unter Software auffindbar

  Szenario: Mögliche Werte in Software-Produkt erfassen
    Angenommen ich befinde mich auf der Software-Erstellungsseite
    Dann die mögliche Werte für Betriebssystem sind in der folgenden Reihenfolge:
      | Betriebssystem |
      | Windows |
      | Mac OS |
      | Mac OS X |
      | Linux |
    Dann die mögliche Werte für Installation sind in der folgenden Reihenfolge:
      | Citrix |
      | Lokal |
      | Web |
    Dann kann ich auf mehreren Zeilen Hinweise und Links anfügen

  @javascript
  Szenario: Mögliche Werte in Software-Lizenz erfassen
    Angenommen ich befinde mich auf der Lizenz-Erstellungsseite
    Dann die mögliche Werte für Aktivierungstyp sind in der folgenden Reihenfolge:
      | Aktivierungstyp |
      | Dongle |
      | Seriennummer |
      | Lizenzserver |
      | Challenge Response/System ID |
      | Keine/r |
    Dann die mögliche Werte für Lizenzstyp sind in der folgenden Reihenfolge:
      | Lizenztsyp |
      | Frei |
      | Einzelplatz |
      | Mehrplatz |
      | Site-Lizenz |
      | Konkurrent |
    Dann die mögliche Werte für Ausleihbar sind in der folgenden Reihenfolge:
      | Ausleihbar |
      | OK |
      | Nicht ausleihbar |
    Und die Option "Ausleihbar" ist standardmässig auf "Nicht ausleihbar" gesetzt

  @javascript
  Szenario: Software-Lizenz erfassen
    Angenommen es existiert ein Software-Produkt
    Wenn ich eine neue Software-Lizenz hinzufüge
    Und ich das Modell setze
    Und eine Inventarnummer vergeben wird
    Und ich eine Seriennummer eingebe
    Und ich eine Aktivierungsart eingebe
    Und ich eine Lizenzart eingebe
    Und ich die den Wert "ausleihbar" setze
    Und ich speichere
    Dann sind die Informationen dieser Software-Lizenz gespeichert
