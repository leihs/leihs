# language: de

Funktionalität: Gegenstand bearbeiten

  Grundlage:
    Angenommen ich bin Matti

  @javascript @personas
  Szenario: Reihenfolge der Felder
    Angenommen man editiert einen Gegenstand, wo man der Besitzer ist
    Wenn I select "Ja" from "item[retired]"
    Wenn I choose "Investition"
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
  Szenario: Lieferanten löschen
    Angenommen man editiert einen Gegenstand, wo man der Besitzer ist
    Angenommen man navigiert zur Bearbeitungsseite eines Gegenstandes mit gesetztem Lieferanten
    Wenn ich den Lieferanten lösche
    Und ich speichere
    Dann ist bei dem bearbeiteten Gegenstand keiner Lieferant eingetragen

  @javascript @personas @browser
  Szenario: Einen Gegenstand mit allen Informationen editieren
    Angenommen man editiert einen Gegenstand, wo man der Besitzer ist, der am Lager und in keinem Vertrag vorhanden ist
    Wenn ich die folgenden Informationen erfasse
      | Feldname               | Type         | Wert                |

      | Inventarcode           |              | Test Inventory Code |
      | Modell                 | autocomplete | Sharp Beamer 456    |

      | Ausmusterung           | select       | Ja                  |
      | Grund der Ausmusterung |              | Ja                  |
      | Zustand                | radio        | OK                  |
      | Vollständigkeit        | radio        | OK                  |
      | Ausleihbar             | radio        | OK                  |

      | Inventarrelevant       | select       | Ja                  |
      | Anschaffungskategorie  | select       | Werkstatt-Technik   |

    Und ich speichere
    Dann man wird zur Liste des Inventars zurueckgefuehrt
    Und ist der Gegenstand mit all den angegebenen Informationen gespeichert

  @javascript @personas
  Szenario: Ein Modell ohne Version für den Gegestand wählen
    Angenommen man editiert einen Gegenstand, wo man der Besitzer ist
    Und ein Modell existiert, welches keine Version hat
    Wenn ich dieses Modell dem Gegestand zuweise
    Dann steht in dem Modellfeld nur der Produktname dieses Modell

  @javascript @personas
  Szenario: Lieferanten ändern
    Angenommen man editiert einen Gegenstand, wo man der Besitzer ist
    Wenn ich den Lieferanten ändere
    Und ich speichere
    Dann ist bei dem bearbeiteten Gegestand der geänderte Lieferant eingetragen

  @javascript @personas @browser
  Szenario: Bei ausgeliehenen Gegenständen kann man die verantwortliche Abteilung nicht editieren
    Angenommen man navigiert zur Bearbeitungsseite eines Gegenstandes, der ausgeliehen ist und wo man Besitzer ist
    Wenn ich die verantwortliche Abteilung ändere
    Und ich speichere
    Dann erhält man eine Fehlermeldung, dass man diese Eigenschaft nicht editieren kann, da das Gerät ausgeliehen ist

  @javascript @personas @browser
  Szenario: Einen Gegenstand mit allen Informationen editieren
    Angenommen man editiert einen Gegenstand, wo man der Besitzer ist, der am Lager und in keinem Vertrag vorhanden ist
    Wenn ich die folgenden Informationen erfasse
      | Feldname              | Type         | Wert                |

      | Inventarcode          |              | Test Inventory Code |
      | Modell                | autocomplete | Sharp Beamer 456    |

      | Inventarrelevant      | select       | Ja                  |
      | Anschaffungskategorie | select       | Werkstatt-Technik   |

      | Umzug                 | select       | sofort entsorgen    |
      | Zielraum              |              | Test Raum           |

      | Ankunftsdatum         |              | 01.01.2013          |
      | Ankunftszustand       | select       | transportschaden    |
      | Ankunftsnotiz         |              | Test Notiz          |

      | Seriennummer          |              | Test Seriennummer   |
      | MAC-Adresse           |              | Test MAC-Adresse    |
      | IMEI-Nummer           |              | Test IMEI-Nummer    |
      | Name                  |              | Test Name           |
      | Notiz                 |              | Test Notiz          |

      | Gebäude               | autocomplete | Keine/r             |
      | Raum                  |              | Test Raum           |
      | Gestell               |              | Test Gestell        |

    Und ich speichere
    Dann man wird zur Liste des Inventars zurueckgefuehrt
    Und ist der Gegenstand mit all den angegebenen Informationen gespeichert

  @javascript @personas
  Szenario: Pflichtfelder
    Angenommen man editiert einen Gegenstand, wo man der Besitzer ist
    Dann muss der "Bezug" unter "Rechnungsinformationen" ausgewählt werden
    Wenn "Investition" bei "Bezug" ausgewählt ist muss auch "Projektnummer" angegeben werden
    Wenn "Ja" bei "Inventarrelevant" ausgewählt ist muss auch "Anschaffungskategorie" ausgewählt werden
    Wenn "Ja" bei "Ausmusterung" ausgewählt ist muss auch "Grund der Ausmusterung" angegeben werden
    Dann sind alle Pflichtfelder mit einem Stern gekenzeichnet
    Wenn ein Pflichtfeld nicht ausgefüllt/ausgewählt ist, dann lässt sich der Gegenstand nicht speichern
    Und ich sehe eine Fehlermeldung
    Und die nicht ausgefüllten/ausgewählten Pflichtfelder sind rot markiert

  @javascript @personas
  Szenario: Neuen Lieferanten erstellen falls nicht vorhanden
    Angenommen man editiert einen Gegenstand, wo man der Besitzer ist
    Wenn ich einen nicht existierenen Lieferanten angebe
    Und ich speichere
    Dann wird der neue Lieferant erstellt
    Und bei dem bearbeiteten Gegestand ist der neue Lieferant eingetragen

  @javascript @personas
  Szenario: Neuen Lieferanten nicht erstellen falls einer mit gleichem Namen schon vorhanden
    Angenommen man editiert einen Gegenstand, wo man der Besitzer ist
    Wenn ich einen existierenen Lieferanten angebe
    Und ich speichere
    Dann wird kein neuer Lieferant erstellt
    Und bei dem bearbeiteten Gegestand ist der bereits vorhandenen Lieferant eingetragen
  

  @javascript @personas
  Szenario: Bei Gegenständen, die in Verträgen vorhanden sind, kann man das Modell nicht ändern
    Angenommen man navigiert zur Bearbeitungsseite eines Gegenstandes, der in einem Vertrag vorhanden ist
    Wenn ich das Modell ändere
    Und ich speichere
    Dann erhält man eine Fehlermeldung, dass man diese Eigenschaft nicht editieren kann, da das Gerät in einem Vortrag vorhanden ist

  @javascript @personas
  Szenario: Einen Gegenstand, der ausgeliehen ist, kann man nicht ausmustern
    Angenommen man navigiert zur Bearbeitungsseite eines Gegenstandes, der ausgeliehen ist und wo man Besitzer ist
    Wenn ich den Gegenstand ausmustere
    Und ich speichere
    Dann erhält man eine Fehlermeldung, dass man den Gegenstand nicht ausmustern kann, da das Gerät bereits ausgeliehen oder einer Vertragslinie zugewiesen ist

  @javascript @personas @browser
  Szenario: Einen Gegenstand mit allen Informationen editieren
    Angenommen man editiert einen Gegenstand, wo man der Besitzer ist, der am Lager und in keinem Vertrag vorhanden ist
    Wenn ich die folgenden Informationen erfasse
      | Feldname              | Type         | Wert                |

      | Inventarcode          |              | Test Inventory Code |
      | Modell                | autocomplete | Sharp Beamer 456    |

      | Inventarrelevant      | select       | Ja                  |
      | Anschaffungskategorie | select       | Werkstatt-Technik   |

      | Bezug                 | radio must   | Investition         |
      | Projektnummer         |              | Test Nummer         |
      | Rechnungsnummer       |              | Test Nummer         |
      | Rechnungsdatum        |              | 01.01.2013          |
      | Anschaffungswert      |              | 50.00               |
      | Garantieablaufdatum   |              | 01.01.2013          |
      | Vertragsablaufdatum   |              | 01.01.2013          |

    Und ich speichere
    Dann man wird zur Liste des Inventars zurueckgefuehrt
    Und ist der Gegenstand mit all den angegebenen Informationen gespeichert

  @javascript @personas @browser
  Szenario: Einen Gegenstand mit allen Informationen editieren
    Angenommen man editiert einen Gegenstand, wo man der Besitzer ist, der am Lager und in keinem Vertrag vorhanden ist
    Wenn ich die folgenden Informationen erfasse
      | Feldname                  | Type         | Wert                |

      | Inventarcode              |              | Test Inventory Code |
      | Modell                    | autocomplete | Sharp Beamer 456    |

      | Inventarrelevant          | select       | Ja                  |
      | Anschaffungskategorie     | select       | Werkstatt-Technik   |
      | Letzte Inventur           |              | 01.01.2013          |
      | Verantwortliche Abteilung | autocomplete | A-Ausleihe          |
      | Verantwortliche Person    |              | Matus Kmit          |
      | Benutzer/Verwendung       |              | Test Verwendung     |

    Und ich speichere
    Dann man wird zur Liste des Inventars zurueckgefuehrt
    Und ist der Gegenstand mit all den angegebenen Informationen gespeichert
