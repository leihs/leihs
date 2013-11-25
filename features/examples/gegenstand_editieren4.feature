# language: de

Funktionalität: Gegenstand bearbeiten
    
  @javascript
  Szenario: Einen Gegenstand mit allen Informationen editieren
    Angenommen Personas existieren
    Und man ist "Matti"
    Und man navigiert zur Gegenstandsbearbeitungsseite eines Gegenstandes, der am Lager und in keinem Vertrag vorhanden ist
    Wenn ich die folgenden Informationen erfasse
      | Feldname                     | Type         | Wert                          |

      | Inventarcode                 |              | Test Inventory Code           |
      | Modell                       | autocomplete | Sharp Beamer                  |

      | Inventarrelevant             | select       | Ja                            |
      | Anschaffungskategorie        | select       | Werkstatt-Technik             |

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

    Und ich speichern druecke
    Dann man wird zur Liste des Inventars zurueckgefuehrt
    Und ist der Gegenstand mit all den angegebenen Informationen gespeichert
