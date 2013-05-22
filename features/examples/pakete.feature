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
    | Ausmusterung                 | checkbox     | unchecked                     |
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
    | Ausmusterung                 | checkbox     | unchecked                     |
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

  @javascript
  Szenario: Paket löschen
    Wenn das Paket zurzeit nicht ausgeliehen ist 
    Dann kann ich das Paket löschen und die Gegenstände sind nicht mehr dem Paket zugeteilt

  @javascript
  Szenario: Paket löschen schlägt fehl wenn das Paket gerade ausgeliehen ist
    Wenn das Paket zurzeit ausgeliehen ist 
    Dann kann ich das Paket nicht löschen

  @javascript
  Szenario: Pakete nicht ohne Gegenstände erstellen
    Wenn ich einem Modell ein Paket hinzufüge
    Dann kann ich dieses Paket nur speichern, wenn dem Paket auch Gegenstände zugeteilt sind

  @javascript
  Szenario: Einzelnen Gegenstand aus Paket entfernen
    Wenn ich ein Paket editiere
    Dann kann ich einen Gegenstand aus dem Paket entfernen
    Und dieser Gegenstand ist nicht mehr dem Paket zugeteilt

  @javascript
  Szenario: Modell mit Paketzuteilung erstellen und wieder editieren
    Wenn ich ein neues Modell hinzufüge
    Und ich mindestens die Pflichtfelder ausfülle
    Und ich eine Paket hinzufüge
    Und ich die Paketeigenschaften eintrage
    Und ich diesem Paket eines oder mehrere Gegenstände hinzufügen
    Und ich dieses Paket speichere
    Und ich dieses Paket wieder editiere
    Dann kann ich die Paketeigenschaften erneut bearbeiten
    Und ich kann diesem Paket eines oder mehrere Gegenstände hinzufügen
