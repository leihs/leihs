# language: de

Funktionalität: Gegenstand bearbeiten

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Matti"
    Und man editiert einen Gegenstand, wo man der Besitzer ist

  @javascript
  Szenario: Pflichtfelder
    Dann muss der "Bezug" unter "Rechnungsinformationen" ausgewählt werden
    Wenn "Investition" bei "Bezug" ausgewählt ist muss auch "Projektnummer" angegeben werden
    Wenn "Ja" bei "Inventarrelevant" ausgewählt ist muss auch "Anschaffungskategorie" ausgewählt werden
    Wenn "Ja" bei "Ausmusterung" ausgewählt ist muss auch "Grund der Ausmusterung" angegeben werden
    Dann sind alle Pflichtfelder mit einem Stern gekenzeichnet
    Wenn ein Pflichtfeld nicht ausgefüllt/ausgewählt ist, dann lässt sich der Gegenstand nicht speichern 
    Und der Benutzer sieht eine Fehlermeldung
    Und die nicht ausgefüllten/ausgewählten Pflichtfelder sind rot markiert

  @javascript
  Szenario: Reihenfolge der Felder
    Wenn I select "Ja" from "item[retired]"
    Wenn I choose "Investition"
    Dann sehe ich die Felder in folgender Reihenfolge:
    | Inventarcode |
    | Modell |
    | - Zustand - |
    | Ausmusterung |
    | Grund der Ausmusterung |
    | Zustand |
    | Vollständigkeit |
    | Ausleihbar |
    | - Inventar - |
    | Inventarrelevant |
    | Anschaffungskategorie |
    | Besitzer |
    | Letzte Inventur |
    | Verantwortliche Abteilung |
    | Verantwortliche Person |
    | Benutzer/Verwendung |
    | - Umzug - |
    | Umzug |
    | Zielraum |
    | - Toni Ankunftskontrolle - |
    | Ankunftsdatum |
    | Ankunftszustand |
    | Ankunftsnotiz |
    | - Allgemeine Informationen - |
    | Seriennummer |
    | MAC-Adresse |
    | IMEI-Nummer |
    | Name |
    | Notiz |
    | - Ort - |
    | Gebäude |
    | Raum |
    | Gestell |
    | - Rechnungsinformationen - |
    | Bezug |
    | Projektnummer |
    | Rechnungsnummer |
    | Rechnungsdatum |
    | Anschaffungswert |
    | Lieferant |
    | Garantieablaufdatum |
    | Vertragsablaufdatum |

  @javascript
  Szenario: Einen Gegenstand mit allen Informationen editieren
    Angenommen Personas existieren
    Und man ist "Matti"
    Und man navigiert zur Gegenstandsbearbeitungsseite eines Gegenstandes, der am Lager und in keinem Vertrag vorhanden ist
    Wenn ich die folgenden Informationen erfasse
      | Feldname                     | Type         | Wert                          |

      | Inventarcode                 |              | Test Inventory Code           |
      | Modell                       | autocomplete | Sharp Beamer                  |

      | Ausmusterung                 | select       | Ja                            |
      | Grund der Ausmusterung       |              | Ja                            |
      | Zustand                      | radio        | OK                            |
      | Vollständigkeit              | radio        | OK                            |
      | Ausleihbar                   | radio        | OK                            |

      | Inventarrelevant             | select       | Ja                            |
      | Anschaffungskategorie        | select       | Werkstatt-Technik             |
      | Letzte Inventur              |              | 01.01.2013                    |
      | Verantwortliche Abteilung    | autocomplete | A-Ausleihe                    |
      | Verantwortliche Person       |              | Matus Kmit                    |
      | Benutzer/Verwendung          |              | Test Verwendung               |

      | Umzug                        | select       | sofort entsorgen              |
      | Zielraum                     |              | Test Raum                     |

      | Ankunftsdatum                |              | 01.01.2013                    |
      | Ankunftszustand              | select       | transportschaden              |
      | Ankunftsnotiz                |              | Test Notiz                    |

      | Seriennummer                 |              | Test Seriennummer             |
      | MAC-Adresse                  |              | Test MAC-Adresse              |
      | IMEI-Nummer                  |              | Test IMEI-Nummer              |
      | Name                         |              | Test Name                     |
      | Notiz                        |              | Test Notiz                    |

      | Gebäude                      | autocomplete | Keine/r                       |
      | Raum                         |              | Test Raum                     |
      | Gestell                      |              | Test Gestell                  |

      | Bezug                        | radio must   | investment                    |
      | Projektnummer                |              | Test Nummer                   |
      | Rechnungsnummer              |              | Test Nummer                   |
      | Rechnungsdatum               |              | 01.01.2013                    |
      | Anschaffungswert             |              | 50.0                          |
      | Garantieablaufdatum          |              | 01.01.2013                    |
      | Vertragsablaufdatum          |              | 01.01.2013                    |

    Und ich speichern druecke
    Dann man wird zur Liste des Inventars zurueckgefuehrt
    Und ist der Gegenstand mit all den angegebenen Informationen gespeichert

  @javascript
  Szenario: Neuen Lieferanten erstellen falls nicht vorhanden
    Angenommen man navigiert zur Gegenstandsbearbeitungsseite
    Wenn ich einen nicht existierenen Lieferanten angebe
    Und ich speichern druecke
    Dann wird der neue Lieferant erstellt
    Und bei dem bearbeiteten Gegestand ist der neue Lieferant eingetragen

  @javascript
  Szenario: Lieferanten löschen
    Angenommen man navigiert zur Bearbeitungsseite eines Gegenstandes mit gesetztem Lieferanten
    Wenn ich den Lieferanten lösche
    Und ich speichern druecke
    Dann ist bei dem bearbeiteten Gegenstand keiner Lieferant eingetragen

  @javascript
  Szenario: Lieferanten ändern
    Angenommen man navigiert zur Gegenstandsbearbeitungsseite
    Wenn ich den Lieferanten ändere
    Und ich speichern druecke
    Dann ist bei dem bearbeiteten Gegestand der geänderte Lieferant eingetragen
