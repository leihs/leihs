# language: de

Funktionalität: Modell mit Paketen erstellen

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Mike"
    Und man öffnet die Liste des Inventars

  @javascript
  Szenario: Modell mit Paketzuteilung erstellen
    Wenn ich ein neues Modell hinzufüge
    Und ich mindestens die Pflichtfelder ausfülle
    Und ich eines oder mehrere Pakete hinzufüge
    Und ich diesem Paket eines oder mehrere Gegenstände hinzufügen
    Und ich das Paket und das Modell speichere
    Dann ist das Modell erstellt und die Pakete und dessen zugeteilten Gegenstände gespeichert
    Und den Paketen wird ein Inventarcode zugewiesen

  @javascript
  Szenario: Modell mit bereits vorhandenen Gegenständen kann kein Paket zugewiesen werden
    Wenn ich ein Modell editiere, welches bereits Gegenstände hat
    Dann kann ich diesem Modell keine Pakete mehr zuweisen

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

  @javascript
  Szenario: Paketeigenschaften abfüllen bei existierendem Modell
    Wenn ich ein Modell editiere, welches bereits Pakete hat
    Und ich ein bestehendes Paket editiere
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
    Dann besitzt das Paket alle angegebenen Informationen


