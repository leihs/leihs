# language: de

Funktionalität: Software erfassen

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Mike"


  Szenario: Software-Produkt erfassen
    Wenn ich ein neues Software hinzufüge
    Und ich erfasse die folgenden Details
      | Feld                               | Wert                       |
      | Produkt                            | Test Software              |
      | Version                            | Test Version               |
      | Hersteller                         | Test Hersteller            |
      | Betriebssystem                     | Windows                    |
      | Installation                       | Citrix                     |
      | Hinweise                           | Installationslink beachten: http://wwww.dokuwiki.ch    |
    Wenn ich speichere
    Dann ist das neue Software erstellt und unter ungenutzen Modellen auffindbar
    

  Szenario: Mögliche Werte in Software-Produkt erfassen
    Wenn ich ein neues Software hinzufüge
    Dann die mögliche Werte für Betriebssystem sind in der folgenden Reihenfolge:
      | Windows |
      | Mac OS |
      | Mac OS X |
      | Linux |
    Dann die mögliche Werte für Installation sind in der folgenden Reihenfolge:
      | Citrix |
      | Lokal |
      | Web |
    Dann kann ich auf mehreren Zeilen Hinweise und Links anfügen
    

  Szenario: Mögliche Werte in Software-Lizenz erfassen
    Wenn ich ein neue Lizenz hinzufüge
    Dann die mögliche Werte für Aktivierungsart sind in der folgenden Reihenfolge:
      | Dongle |
      | Seriennummer |
      | Lizenzserver |
      | Challenge Response/System ID |
      | keine |
    Dann die mögliche Werte für Lizenzart sind in der folgenden Reihenfolge:
      | frei |
      | Einzelplatz |
      | Mehrplatz |
      | Site-Lizenz |
      | Konkurrent |
    Dann die mögliche Werte für Ausleihbar sind in der folgenden Reihenfolge:
      | OK |
      | Nicht ausleihbar |
      Und die Option "Ausleihbar" ist standardmässig auf "Nicht ausleihbar" gesetzt
      

  Szenario: Software-Lizenz erfassen
    Angenommen es existiert ein Software-Produkt
    Wenn ich eine neue Software-Lizenz erfasse
    Und ich ein Produkt auswähle
    Und eine Inventarnummer vergeben wird
    Und ich eine Lizenznummer eingebe
    Und ich eine Aktivierungsart eingebe
    Und ich eine Lizenzart eingebe
    Und ich die den Wert "ausleihbar" setze
    Und ich speichere
    Dann sind die Informationen dieser Software-Lizenz gespeichert
