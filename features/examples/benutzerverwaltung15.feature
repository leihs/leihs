# language: de

Funktionalität: Benutzer verwalten 

  Grundlage:
    Angenommen Personas existieren

  @javascript
  Szenario: Elemente der Benutzeradministration
    Angenommen man ist Inventar-Verwalter oder Ausleihe-Verwalter
    Dann findet man die Benutzeradministration im Bereich "Administration" unter "Benutzer"
    Dann sieht man eine Liste aller Benutzer
    Und man kann filtern nach den folgenden Eigenschaften: gesperrt
    Und man kann filtern nach den folgenden Rollen:
      | tab                | role               |
      | Kunde              | customers          |
      | Ausleihe-Verwalter | lending_managers   |
      | Inventar-Verwalter | inventory_managers |
    Und man kann für jeden Benutzer die Editieransicht aufrufen
