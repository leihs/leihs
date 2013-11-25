# language: de

Funktionalität: Modell mit Paketen erstellen

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Mike"
    Und man öffnet die Liste des Inventars

  @javascript
  Szenario: Paketeigenschaften abfüllen bei neu erstelltem Modell
    Wenn ich einem Modell ein Paket hinzufüge
    Und ich diesem Paket eines oder mehrere Gegenstände hinzufügen
    Und ich die folgenden Informationen erfasse
    | Feldname                     | Type         | Wert                          |
    | Zustand                      | radio        | OK                            |
    | Vollständigkeit              | radio        | OK                            |
    | Ausleihbar                   | radio        | OK                            |
    | Inventarrelevant             | select       | Ja                            |
    | Letzte Inventur              |              | 01.01.2013                    |
    | Verantwortliche Abteilung    | autocomplete | A-Ausleihe                    |
    | Verantwortliche Person       |              | Matus Kmit                    |
    | Benutzer/Verwendung          |              | Test Verwendung               |
    | Name                         |              | Test Name                     |
    | Notiz                        |              | Test Notiz                    |
    | Gebäude                      | autocomplete | Keine/r                       |
    | Raum                         |              | Test Raum                     |
    | Gestell                      |              | Test Gestell                  |
    | Anschaffungswert             |              | 50.0                          |
    Und ich das Paket und das Modell speichere
    Dann sehe ich die Meldung "Modell gespeichert / Pakete erstellt"
    Und das Paket besitzt alle angegebenen Informationen
