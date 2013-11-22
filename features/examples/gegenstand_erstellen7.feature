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

    | Bezug                        | radio must   | investment                    |
    | Projektnummer                |              | Test Nummer                   |
    | Rechnungsnummer              |              | Test Nummer                   |
    | Rechnungsdatum               |              | 01.01.2013                    |
    | Anschaffungswert             |              | 50.0                          |
    | Garantieablaufdatum          |              | 01.01.2013                    |
    | Vertragsablaufdatum          |              | 01.01.2013                    |

    Und ich erstellen druecke
    Dann man wird zur Liste des Inventars zurueckgefuehrt
    Und ist der Gegenstand mit all den angegebenen Informationen erstellt
