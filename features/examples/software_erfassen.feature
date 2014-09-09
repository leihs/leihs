# language: de

Funktionalität: Software erfassen

  Grundlage:
    Angenommen ich bin Mike

  @javascript @personas
  Szenario: Software-Produkt erfassen
    Wenn ich eine neue Software hinzufüge
    Und ich erfasse die folgenden Details
      | Feld                               | Wert                       |
      | Produkt                            | Test Software              |
      | Version                            | Test Version               |
      | Software Informationen             | Installationslink beachten: http://wwww.dokuwiki.ch\n\nDies ist nur ein Text |
    Wenn der Hersteller bereits existiert
    Dann kann der Hersteller aus der Liste ausgewählt werden
    Wenn ich einen nicht existierenden Hersteller eingebe
    Und ich speichere
    Dann ist die neue Software erstellt und unter Software auffindbar
    Wenn ich das Software-Produkt wieder editiere
    Dann werden nur die Linien mit Links zusätzlich ausserhalb des Textfeldes angezeigt
    Und der neue Hersteller ist in der Herstellerliste auffindbar

  # marked as upcoming due to ticket 71745006
  @upcoming @javascript @personas
  Szenario: Mögliche Werte in Software-Lizenz erfassen
    Angenommen ich befinde mich auf der Lizenz-Erstellungsseite
    Dann die mögliche Werte für Aktivierungstyp sind in der folgenden Reihenfolge:
      | Aktivierungstyp |
      | Keine/r |
      | Dongle |
      | Seriennummer |
      | Lizenzserver |
      | Challenge Response/System ID |
      Dann die mögliche Werte für Lizenztyp sind in der folgenden Reihenfolge:
      | Lizenztyp |
      | Frei |
      | Einzelplatz |
      | Mehrplatz |
      | Site-Lizenz |
      | Konkurrent |
    Dann die mögliche Werte für Ausleihbar sind in der folgenden Reihenfolge:
      | Ausleihbar |
      | OK |
      | Nicht ausleihbar |
    Dann kann man als "Betriebssystem" keine, eine oder mehrere der folgenden Möglichkeiten in Form einer Checkbox auswählen:
      | Betriebssystem |
      | Windows |
      | Mac OS X |
      | Linux |
      | iOS |
    Dann kann man als "Installation" keine, eine oder mehrere der folgenden Möglichkeiten in Form einer Checkbox auswählen:
      | Citrix |
      | Lokal |
      | Web |
    Dann kann man als "Bezug" einen der folgenden Möglichkeiten anhand eines Radio-Buttons wählen:
      |laufende Rechnung|
      |Investition                 |
    Dann kann man als "Lizenzablaufdatum" ein Datum auswählen
    Dann die mögliche Werte für Maintenance-Vertrag sind in der folgenden Reihenfolge:
      | Nein |
      | Ja   |
    Dann kann man als "Rechnungsdatum" ein Datum auswählen
    Dann kann man als "Anschaffungswert" eine Zahl eingeben
    Dann kann man als "Beschafft durch" einen Benutzer wählen
    Dann kann man als "Lieferant" einen Lieferanten auswählen
    Dann kann man als "Verantwortliche Abteilung" einen Gerätepark auswählen
    Dann kann man als "Besitzer" einen Gerätepark auswählen
    Dann kann man als "Notiz" einen Text eingeben
    Und die Option "Ausleihbar" ist standardmässig auf "Nicht ausleihbar" gesetzt

  @javascript @personas
  Szenario: Software-Lizenz erfassen
    Angenommen es existiert ein Software-Produkt
    Wenn ich eine neue Software-Lizenz hinzufüge
    Und ich die Software setze
    Und ein neuer Inventarcode vergeben wird
    Und ich eine Seriennummer eingebe
    Wenn ich als Aktivierungsart Dongle wähle
    Dann muss ich eine Dongle-ID eingeben
    Wenn ich einen der folgenden Lizenztypen wähle:
      | Mehrplatz   |
      | Konkurrent  |
      | Site-Lizenz |
    Und ich eine Gesamtanzahl eingebe
    Und ich die Anzahl-Zuteilungen hinzufüge
    Und ich als Betriebssystem keine, eine oder mehrere der vorhandenen Möglichkeiten auswähle
    Und ich als Installation keine, eine oder mehrere der vorhandenen Möglichkeiten auswähle
    Und ich als Lizenzablaufdatum ein Datum auswähle
    Wenn ich als Maintenance-Vertrag "Nein" auswähle
    Dann kann ich für den Maintenance-Vertrag kein Ablaufdatum wählen
    Wenn ich als Maintenance-Vertrag "Ja" auswähle
    Und ich für den Maintenance-Vertrag ein Ablaufdatum wähle
    Wenn ich als Bezug "Investition" wähle
    Dann muss ich eine Projektnummer eingeben
    Und ich die den Wert "ausleihbar" setze
    Und ich speichere
    Dann sind die Informationen dieser Software-Lizenz gespeichert

  @personas @javascript @firefox
  Szenario: Lizenzanzahl bei Mehrplatz/Konkurrent/Site-Lizenzen
    Angenommen es existiert ein Software-Produkt
    Wenn ich eine neue Software-Lizenz hinzufüge
    Und ich alle Pflichtfelder für die Lizenz ausfülle
    Wenn ich einen der folgenden Lizenztypen wähle:
      | Mehrplatz   |
      | Konkurrent  |
      | Site-Lizenz |
    Und ich die Gesamtanzahl "50" eingebe
    Dann wird mir die verbleibende Anzahl der Lizenzen wie folgt angezeigt "verbleibend 50"
    Und ich die folgenden Anzahl-Zuteilungen hinzufüge
      | Anzahl   | Text | 
      | 1        | Christina Meier| 
      | 10       | Raum ITZ.Z40| 
    Dann wird mir die verbleibende Anzahl der Lizenzen wie folgt angezeigt "verbleibend 39"
    Und ich die folgenden Anzahl-Zuteilungen hinzufüge
      | Anzahl   | Text | 
      | 40       | Raum Z50 | 
    Dann wird mir die verbleibende Anzahl der Lizenzen wie folgt angezeigt "verbleibend -1"
    Wenn ich die folgenden Anzahl-Zuteilungen lösche
      | Anzahl   | Text | 
      | 1        | Christina Meier| 
    Dann wird mir die verbleibende Anzahl der Lizenzen wie folgt angezeigt "verbleibend 0" 

  @javascript @personas
  Szenario: Software-Lizenz Anschaffungswert mit 2 Dezimalstellen erfassen
    Angenommen es existiert ein Software-Produkt
    Wenn ich eine neue Software-Lizenz hinzufüge
    Und ich alle Pflichtfelder für die Lizenz ausfülle
    Und ich im Feld "Anschaffungswert" den Wert "1200" eingebe
    Und ich speichere
    Dann ist der "Anschaffungswert" als "1'200.00" gespeichert
