# language: de

Funktionalität: Gegenstand erstellen

  @javascript @personas
  Szenario: Felder beim Erstellen eines Gegenstandes
    Angenommen ich bin Matti
    Und man navigiert zur Gegenstandserstellungsseite
    Und I select "Ja" from "item[retired]"
    Und I choose "Investition"
    Dann sehe ich die Felder in folgender Reihenfolge:
    | Inventarcode                 |
    | Modell                       |
    | - Zustand -                  |
    | Ausmusterung                 |
    | Grund der Ausmusterung       |
    | Zustand                      |
    | Vollständigkeit              |
    | Ausleihbar                   |
    | - Inventar -                 |
    | Inventarrelevant             |
    | Anschaffungskategorie        |    
    | Besitzer                     |
    | Letzte Inventur              |
    | Verantwortliche Abteilung    |
    | Verantwortliche Person       |
    | Benutzer/Verwendung          |
    | - Umzug -                    |
    | Umzug                        |
    | Zielraum                     |
    | - Toni Ankunftskontrolle -   |
    | Ankunftsdatum                |
    | Ankunftszustand              |
    | Ankunftsnotiz                |
    | - Allgemeine Informationen - |
    | Seriennummer                 |
    | MAC-Adresse                  |
    | IMEI-Nummer                  |
    | Name                         |
    | Notiz                        |
    | - Ort -                      |
    | Gebäude                      |
    | Raum                         |
    | Gestell                      |
    | - Rechnungsinformationen -   |
    | Bezug                        |
    | Projektnummer                |
    | Rechnungsnummer              |
    | Rechnungsdatum               |
    | Anschaffungswert             |
    | Lieferant                    |
    | Garantieablaufdatum          |
    | Vertragsablaufdatum          |

  @javascript @personas
  Szenario: Einen Gegenstand mit allen fehlenden Pflichtangaben erstellen
    Angenommen ich bin Matti
    Und man navigiert zur Gegenstandserstellungsseite
    Und man setzt Bezug auf Investition
    Und kein Pflichtfeld ist gesetzt
    | Modell        |
    | Inventarcode  |
    | Projektnummer |
    | Anschaffungskategorie  |
    Dann kann das Modell nicht erstellt werden
    Und ich sehe eine Fehlermeldung

  @javascript @personas
  Szenario: Einen Gegenstand mit einer fehlenden Pflichtangabe erstellen
    Angenommen ich bin Matti
    Und man navigiert zur Gegenstandserstellungsseite
    Und man setzt Bezug auf Investition
    Und jedes Pflichtfeld ist gesetzt
    | Modell        |
    | Inventarcode  |
    | Projektnummer |
    | Anschaffungskategorie |
    Wenn ich das gekennzeichnete "Modell" leer lasse
    Dann kann das Modell nicht erstellt werden
    Und ich sehe eine Fehlermeldung
    Und die anderen Angaben wurde nicht gelöscht

  @javascript @personas
  Szenario: Einen Gegenstand mit einer fehlenden Pflichtangabe erstellen
    Angenommen ich bin Matti
    Und man navigiert zur Gegenstandserstellungsseite
    Und man setzt Bezug auf Investition
    Und jedes Pflichtfeld ist gesetzt
    | Modell        |
    | Inventarcode  |
    | Projektnummer |
    | Anschaffungskategorie |
    Wenn ich das gekennzeichnete "Inventarcode" leer lasse
    Dann kann das Modell nicht erstellt werden
    Und ich sehe eine Fehlermeldung
    Und die anderen Angaben wurde nicht gelöscht

  @javascript @personas
  Szenario: Wo man einen Gegenstand erstellen kann
    Angenommen ich bin Matti
    Und man befindet sich auf der Liste des Inventars
    Dann kann man einen Gegenstand erstellen

  @javascript @personas
  Szenario: Neuen Lieferanten erstellen falls nicht vorhanden
    Angenommen ich bin Mike
    Und ich befinde mich auf der Erstellungsseite eines Gegenstandes
    Und jedes Pflichtfeld ist gesetzt
      | Modell        |
      | Inventarcode  |
      | Projektnummer |
      | Anschaffungskategorie |
    Wenn ich einen nicht existierenen Lieferanten angebe
    Und ich erstellen druecke
    Dann wird der neue Lieferant erstellt
    Und bei dem erstellten Gegestand ist der neue Lieferant eingetragen

  @javascript @personas @browser
  Szenario: Einen Gegenstand mit allen Informationen erstellen
    Angenommen ich bin Matti
    Und man navigiert zur Gegenstandserstellungsseite
    Wenn ich die folgenden Informationen erfasse
    | Feldname                     | Type         | Wert                          |

    | Inventarcode                 |              | Test Inventory Code           |
    | Modell                       | autocomplete | Sharp Beamer 456              |

    | Inventarrelevant             | select       | Ja                            |
    | Anschaffungskategorie        | select       | Werkstatt-Technik             | 
    | Letzte Inventur              |              | 01.01.2013                    |
    | Verantwortliche Abteilung    | autocomplete | A-Ausleihe                    |
    | Verantwortliche Person       |              | Matus Kmit                    |
    | Benutzer/Verwendung          |              | Test Verwendung               |

    | Ankunftsdatum                |              | 01.01.2013                    |
    | Ankunftszustand              | select       | transportschaden              |
    | Ankunftsnotiz                |              | Test Notiz                    |

    Und ich erstellen druecke
    Dann man wird zur Liste des Inventars zurueckgefuehrt
    Und ist der Gegenstand mit all den angegebenen Informationen erstellt

  @javascript @personas @browser
  Szenario: Einen Gegenstand mit allen Informationen erstellen
    Angenommen ich bin Matti
    Und man navigiert zur Gegenstandserstellungsseite
    Wenn ich die folgenden Informationen erfasse
    | Feldname                     | Type         | Wert                          |

    | Inventarcode                 |              | Test Inventory Code           |
    | Modell                       | autocomplete | Sharp Beamer 456              |

    | Ausmusterung                 | select       | Nein                          |
    | Zustand                      | radio        | OK                            |
    | Vollständigkeit              | radio        | OK                            |
    | Ausleihbar                   | radio        | OK                            |

    | Inventarrelevant             | select       | Ja                            |
    | Anschaffungskategorie        | select       | Werkstatt-Technik             | 

    | Gebäude                      | autocomplete | Keine/r                       |
    | Raum                         |              | Test Raum                     |
    | Gestell                      |              | Test Gestell                  |

    Und ich erstellen druecke
    Dann man wird zur Liste des Inventars zurueckgefuehrt
    Und ist der Gegenstand mit all den angegebenen Informationen erstellt

  @javascript @personas
  Szenario: Einen Gegenstand mit einer fehlenden Pflichtangabe erstellen
    Angenommen ich bin Matti
    Und man navigiert zur Gegenstandserstellungsseite
    Und man setzt Bezug auf Investition
    Und jedes Pflichtfeld ist gesetzt
    | Modell        |
    | Inventarcode  |
    | Projektnummer |
    | Anschaffungskategorie |
    Wenn ich das gekennzeichnete "Projektnummer" leer lasse
    Dann kann das Modell nicht erstellt werden
    Und ich sehe eine Fehlermeldung
    Und die anderen Angaben wurde nicht gelöscht

  @javascript @personas
  Szenario: Einen Gegenstand mit einer fehlenden Pflichtangabe erstellen
    Angenommen ich bin Matti
    Und man navigiert zur Gegenstandserstellungsseite
    Und man setzt Bezug auf Investition
    Und jedes Pflichtfeld ist gesetzt
    | Modell        |
    | Inventarcode  |
    | Projektnummer |
    | Anschaffungskategorie |
    Wenn ich das gekennzeichnete "Anschaffungskategorie" leer lasse
    Dann kann das Modell nicht erstellt werden
    Und ich sehe eine Fehlermeldung
    Und die anderen Angaben wurde nicht gelöscht

  @javascript @personas @browser
  Szenario: Einen Gegenstand mit allen Informationen erstellen
    Angenommen ich bin Matti
    Und man navigiert zur Gegenstandserstellungsseite
    Wenn ich die folgenden Informationen erfasse
    | Feldname                     | Type         | Wert                          |

    | Inventarcode                 |              | Test Inventory Code           |
    | Modell                       | autocomplete | Sharp Beamer 456              |

    | Inventarrelevant             | select       | Ja                            |
    | Anschaffungskategorie        | select       | Werkstatt-Technik             | 

    | Bezug                        | radio must   | Investition                   |
    | Projektnummer                |              | Test Nummer                   |
    | Rechnungsnummer              |              | Test Nummer                   |
    | Rechnungsdatum               |              | 01.01.2013                    |
    | Anschaffungswert             |              | 50.00                         |
    | Garantieablaufdatum          |              | 01.01.2013                    |
    | Vertragsablaufdatum          |              | 01.01.2013                    |

    Und ich erstellen druecke
    Dann man wird zur Liste des Inventars zurueckgefuehrt
    Und ist der Gegenstand mit all den angegebenen Informationen erstellt

  @javascript @personas @browser
  Szenario: Einen Gegenstand mit allen Informationen erstellen
    Angenommen ich bin Matti
    Und man navigiert zur Gegenstandserstellungsseite
    Wenn ich die folgenden Informationen erfasse
    | Feldname                     | Type         | Wert                          |

    | Inventarcode                 |              | Test Inventory Code           |
    | Modell                       | autocomplete | Sharp Beamer 456              |

    | Inventarrelevant             | select       | Ja                            |
    | Anschaffungskategorie        | select       | Werkstatt-Technik             | 
    | Umzug                        | select       | sofort entsorgen              |
    | Zielraum                     |              | Test Raum                     |

    | Seriennummer                 |              | Test Seriennummer             |
    | MAC-Adresse                  |              | Test MAC-Adresse              |
    | IMEI-Nummer                  |              | Test IMEI-Nummer              |
    | Name                         |              | Test Name                     |
    | Notiz                        |              | Test Notiz                    |

    Und ich erstellen druecke
    Dann man wird zur Liste des Inventars zurueckgefuehrt
    Und ist der Gegenstand mit all den angegebenen Informationen erstellt

  @javascript @personas
  Szenario: Wo man einen Gegenstand erstellen kann
    Angenommen ich bin Matti
    Und man befindet sich auf der Liste des Inventars
    Dann kann man einen Gegenstand erstellen

  @javascript @personas
  Szenario: Felder die bereits vorausgefüllt sind
    Angenommen ich bin Matti
    Und man navigiert zur Gegenstandserstellungsseite
    Dann ist der Barcode bereits gesetzt
    Und Letzte Inventur ist das heutige Datum
    Und folgende Felder haben folgende Standardwerte
    | Feldname         | Type             | Wert             |
    | Ausleihbar       | radio            | Nicht ausleihbar |
    | Inventarrelevant | select           | Ja               |
    | Zustand          | radio            | OK               |
    | Vollständigkeit  | radio            | OK               |
    | Anschaffungskategorie  | select     |                  |

  @javascript @personas
  Szenario: Werte für Anschaffungskategorie hinterlegen
    Angenommen ich bin Matti
    Und man navigiert zur Gegenstandserstellungsseite
    Dann sind die folgenden Werte im Feld Anschaffungskategorie hinterlegt
    | Anschaffungskategorie |
    | Werkstatt-Technik     |
    | Produktionstechnik    |
    | AV-Technik            |
    | Musikinstrumente      |
    | Facility Management   |
    | IC-Technik/Software   |
