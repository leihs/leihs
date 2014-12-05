# language: de

Funktionalität: Software kopieren

  Grundlage:
    Angenommen ich bin Mike

  @personas @javascript @browser
  Szenario: Software kopieren
    Angenommen es existiert eine Software-Lizenz
    Wenn ich eine bestehende Software-Lizenz kopiere
    Dann wird die Editieransicht der neuen Software-Lizenz geöffnet
    Und der Titel heisst "Neue Software-Lizenz erstellen"
    Und der Speichern-Button heisst "Lizenz speichern"
    Und ein neuer Inventarcode vergeben wird
    Wenn ich speichere
    Dann ist die neue Lizenz erstellt
    Und wurden die folgenden Felder von der kopierten Lizenz übernommen
      | Software                  |
      | Bezug                     |
      | Besitzer                  |
      | Verantwortliche Abteilung |
      | Rechnungsdatum            |
      | Anschaffungswert          |
      | Lieferant                 |
      | Beschafft durch           |
      | Notiz                     |
      | Aktivierungstyp           |
      | Lizenztyp                 |
      | Gesamtanzahl              |
      | Betriebssystem            |
      | Installation              |
      | Lizenzablaufdatum         |
      | Maintenance-Vertrag       |
      | Maintenance-Ablaufdatum   |
      | Währung                   |
      | Preis                     |

  @personas @javascript @browser
  Szenario: Wo kann Software kopiert werden
    Angenommen es existiert eine Software-Lizenz
    Wenn man im Inventar Bereich ist
    Dann kann ich die bestehende Software-Lizenz kopieren
    Wenn ich mich in der Editieransicht einer Sofware-Lizenz befinde
    Dann kann ich die bestehende Software-Lizenz speichern und kopieren
