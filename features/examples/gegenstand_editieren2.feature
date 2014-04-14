# language: de

Funktionalität: Gegenstand bearbeiten

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Matti"
    Und man editiert einen Gegenstand, wo man der Besitzer ist
    
  @javascript
  Szenario: Einen Gegenstand mit allen Informationen editieren
    Angenommen Personas existieren
    Und man ist "Matti"
    Und man navigiert zur Gegenstandsbearbeitungsseite eines Gegenstandes, der am Lager und in keinem Vertrag vorhanden ist
    Wenn ich die folgenden Informationen erfasse
      | Feldname                     | Type         | Wert                          |

      | Inventarcode                 |              | Test Inventory Code           |
      | Modell                       | autocomplete | Sharp Beamer Test             |

      | Ausmusterung                 | select       | Ja                            |
      | Grund der Ausmusterung       |              | Ja                            |
      | Zustand                      | radio        | OK                            |
      | Vollständigkeit              | radio        | OK                            |
      | Ausleihbar                   | radio        | OK                            |

      | Inventarrelevant             | select       | Ja                            |
      | Anschaffungskategorie        | select       | Werkstatt-Technik             |

    Und ich speichern druecke
    Dann man wird zur Liste des Inventars zurueckgefuehrt
    Und ist der Gegenstand mit all den angegebenen Informationen gespeichert
