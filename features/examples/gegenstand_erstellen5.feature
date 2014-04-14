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
    | Modell                       | autocomplete | Sharp Beamer Test             |

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
