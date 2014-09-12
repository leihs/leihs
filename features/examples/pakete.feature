# language: de

Funktionalität: Modell mit Paketen erstellen

  Grundlage:
    Angenommen ich bin Mike
    Und man öffnet die Liste des Inventars

  @javascript @browser @personas
  Szenario: Modell mit Paketzuteilung erstellen
    Wenn ich ein neues Modell hinzufüge
    Und ich mindestens die Pflichtfelder ausfülle
    Und ich eines oder mehrere Pakete hinzufüge
    Und ich diesem Paket eines oder mehrere Gegenstände hinzufügen
    Und ich das Paket und das Modell speichere
    Dann ist das Modell erstellt und die Pakete und dessen zugeteilten Gegenstände gespeichert
    Und den Paketen wird ein Inventarcode zugewiesen

  @javascript @browser @personas
  Szenario: Modell mit bereits vorhandenen Gegenständen kann kein Paket zugewiesen werden
    Wenn ich ein Modell editiere, welches bereits Gegenstände hat
    Dann kann ich diesem Modell keine Pakete mehr zuweisen

  @javascript @browser @personas
  Szenario: Pakete nicht ohne Gegenstände erstellen
    Wenn ich einem Modell ein Paket hinzufüge
    Dann kann ich dieses Paket nur speichern, wenn dem Paket auch Gegenstände zugeteilt sind

  @javascript @browser @personas
  Szenario: Einzelnen Gegenstand aus Paket entfernen
    Wenn ich ein Paket editiere
    Dann kann ich einen Gegenstand aus dem Paket entfernen
    Und dieser Gegenstand ist nicht mehr dem Paket zugeteilt

  @javascript @browser @personas
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
    | Anschaffungswert             |              | 50.00                         |
    | Letzte Inventur              |              | 01.01.2013                    |
    Und ich das Paket und das Modell speichere
    Dann besitzt das Paket alle angegebenen Informationen

  @javascript @browser @personas
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

  #74210792
  @javascript @browser @personas
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
    | Anschaffungswert             |              | 50.00                         |
    Und ich das Paket und das Modell speichere
    Dann sehe ich die Meldung "Modell gespeichert / Pakete erstellt"
    Und besitzt das Paket alle angegebenen Informationen
    Und alle die zugeteilten Gegenstände erhalten dieselben Werte, die auf diesem Paket erfasst sind
    | Feldname                   |
    | Verantwortliche Abteilung  |
    | Verantwortliche Person     |
    | Gebäude                    |
    | Raum                       |
    | Gestell                    |
    | Toni-Ankunftsdatum         |
    | Letzte Inventur            |


  @javascript @personas
  Szenario: Paket löschen
    Wenn das Paket zurzeit nicht ausgeliehen ist 
    Dann kann ich das Paket löschen und die Gegenstände sind nicht mehr dem Paket zugeteilt

  @personas
  Szenario: Paket löschen schlägt fehl wenn das Paket gerade ausgeliehen ist
    Wenn das Paket zurzeit ausgeliehen ist 
    Dann kann ich das Paket nicht löschen

  @personas @javascript @browser
  Szenario: Nur meine Pakete werden im Modell angezeigt
    Wenn ich ein Modell editiere, welches bereits Pakete in meine und andere Gerätepark hat
    Dann sehe ich nur diejenigen Pakete, für welche ich verantwortlich bin
