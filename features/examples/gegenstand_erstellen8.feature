# language: de

Funktionalität: Gegenstand erstellen

  @javascript
  Szenario: Einen Gegenstand mit allen Informationen erstellen
    Angenommen Personas existieren
    Und man ist "Matti"
    Und man navigiert zur Gegenstandserstellungsseite
    Wenn ich die folgenden Informationen erfasse
    | Feldname                     | Type         | Wert                          |

    | Inventarcode                 |              | Test Inventory Code           |
    | Modell                       | autocomplete | Sharp Beamer                  |

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
