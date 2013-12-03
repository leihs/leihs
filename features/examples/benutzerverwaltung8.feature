# language: de

Funktionalität: Benutzer verwalten 

  Grundlage:
    Angenommen Personas existieren

  @javascript
  Szenario: Neuen Benutzer im Geräterpark als Administrator hinzufügen
    Angenommen man ist "Gino"
    Wenn man in der Benutzeransicht ist
    Und man einen Benutzer hinzufügt
    Und die folgenden Informationen eingibt
      | Nachname       |
      | Vorname        |
      | E-Mail         |
    Und man gibt die Login-Daten ein
    Und man gibt eine Badge-Id ein
    Und man hat nur die folgenden Rollen zur Auswahl
      | No access          |
      | Customer           |
      | Lending manager    |
      | Inventory manager  |
    Und eine der folgenden Rollen auswählt
      | tab                | role                |
      | Kunde              | customer            |
      | Ausleihe-Verwalter | lending_manager     |
      | Inventar-Verwalter | inventory_manager   |
    Und man teilt mehrere Gruppen zu
    Und man speichert den Benutzer
    Dann ist der Benutzer mit all den Informationen gespeichert

  @javascript
  Szenariogrundriss: Neuen Benutzer hinzufügen - ohne Eingabe der Pflichtfelder
    Angenommen man ist "Pius"
    Wenn man in der Benutzeransicht ist
    Und man einen Benutzer hinzufügt
    Und alle Pflichtfelder sind sichtbar und abgefüllt
    Wenn man ein <Pflichtfeld> nicht eingegeben hat
    Und man speichert den Benutzer
    Dann sehe ich eine Fehlermeldung

    Beispiele:
      | Pflichtfeld |
      | Nachname    |
      | Vorname     |
      | E-Mail      |
