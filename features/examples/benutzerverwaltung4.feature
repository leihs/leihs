# language: de

Funktionalität: Benutzer verwalten 

  Grundlage:
    Angenommen Personas existieren

  @javascript
  Szenario: Zugriff entfernen als Inventar-Verwalter
    Angenommen man ist "Mike"
    Und man editiert einen Benutzer der Zugriff auf das aktuelle Inventarpool hat und keine Gegenstände mehr zurückzugeben hat
    Wenn man den Zugriff entfernt
    Und ich speichere
    Dann hat der Benutzer keinen Zugriff auf das Inventarpool

  @javascript @upcoming
  Szenario: Gruppenzuteilung in Benutzeransicht hinzufügen/entfernen
    Angenommen man ist "Pius"
    Und man editiert einen Benutzer
    Dann kann man Gruppen über eine Autocomplete-Liste hinzufügen
    Und kann Gruppen entfernen
    Und speichert den Benutzer
    Dann ist die Gruppenzugehörigkeit gespeichert 

  @javascript
  Szenario: Neuen Benutzer im Geräterpark als Inventar-Verwalter hinzufügen
    Angenommen man ist "Mike"
    Wenn man in der Benutzeransicht ist
    Und man einen Benutzer hinzufügt
    Und die folgenden Informationen eingibt
      | Nachname       |
      | Vorname        |
      | Adresse        |
      | PLZ            |
      | Ort            |
      | Land           |
      | Telefon        |
      | E-Mail         |
    Und man gibt die Login-Daten ein
    Und man gibt eine Badge-Id ein
    Und man hat nur die folgenden Rollen zur Auswahl
      | No access          |
      | Customer           |
      | Group manager      |
      | Lending manager    |
      | Inventory manager  |
    Und eine der folgenden Rollen auswählt
    | tab                | role                |
    | Kunde              | customer            |
    | Gruppen-Verwalter  | group_manager       |
    | Ausleihe-Verwalter | lending_manager     |
    | Inventar-Verwalter | inventory_manager   |
    Und man teilt mehrere Gruppen zu
    Und ich speichere
    Dann ist der Benutzer mit all den Informationen gespeichert
