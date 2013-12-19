# language: de

Funktionalität: Modell mit Paketen erstellen

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Mike"
    Und man öffnet die Liste des Inventars

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
    | Verantwortliche Abteilung    | autocomplete | A-Ausleihe                    |
    | Verantwortliche Person       |              | Matus Kmit                    |
    | Benutzer/Verwendung          |              | Test Verwendung               |
    | Name                         |              | Test Name                     |
    | Notiz                        |              | Test Notiz                    |
    | Gebäude                      | autocomplete | Keine/r                       |
    | Raum                         |              | Test Raum                     |
    | Gestell                      |              | Test Gestell                  |
    | Anschaffungswert             |              | 50.0                          |
    | Letzte Inventur              |              | 01.01.2013                    |
    Und ich das Paket und das Modell speichere
    Dann besitzt das Paket alle angegebenen Informationen
