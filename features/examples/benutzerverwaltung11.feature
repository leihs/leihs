# language: de

Funktionalität: Benutzer verwalten 

  Grundlage:
    Angenommen Personas existieren

  @javascript
  Szenario: Neuen Benutzer im Geräterpark als Ausleihe-Verwalter hinzufügen
    Angenommen man ist "Pius"
    Wenn man in der Benutzeransicht ist
    Und man einen Benutzer hinzufügt
    Und die folgenden Informationen eingibt
      | Nachname       |
      | Vorname        |
      | E-Mail         |
    Und man gibt die Login-Daten ein
    Und man gibt eine Badge-Id ein
    Und man hat nur die folgenden Rollen zur Auswahl
      | No access |
      | Customer  |
      | Group manager  |
      | Lending manager  |
    Und eine der folgenden Rollen auswählt
      | tab                | role              |
      | Kunde              | customer          |
      | Gruppen-Verwalter  | group_manager   |
      | Ausleihe-Verwalter | lending_manager   |
    Und man teilt mehrere Gruppen zu
    Und ich speichere
    Dann ist der Benutzer mit all den Informationen gespeichert

