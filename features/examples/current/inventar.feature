# language: de

Funktionalität: Inventar


  Grundlage:
    Angenommen man ist "Mike"

  @javascript
  Szenario: Was man auf einer Liste sieht
    Wenn man eine Liste von Inventar sieht
    Dann sieht man Modelle
    Und man sieht Optionen
    Und man sieht Pakete

  @wip @javascript
  Szenario: Auswahlmöglichkeiten
    Wenn man eine Liste von Inventar sieht
    Dann hat man folgende Auswahlmöglichkeiten:
    | auswahlmöglichkeit |
    | Alles              |
    | Ausgemustert       |
    | Ausleihbar         |
    | Nicht ausleihbar   |
    Und die Auswahlmöglichkeiten können nicht kombiniert werden

  @wip @javascript
  Szenario: Filtermöglichkeiten von Listen
    Wenn man eine Liste von Inventar sieht
    Dann hat man folgende Filtermöglichkeiten
    | filtermöglichkeit         |
    | An Lager                  |
    | Besitzer bin ich          |
    | Verantwortliche Abteilung |
    | Status                    |
    Und die Filter können kombiniert werden

  Szenario: Grundeinstellung der Listenansicht
    Wenn man eine Liste von Inventar sieht
    Dann ist erstmal die Auswahl "Alles" aktiviert
    Und es sind keine Filtermöglichkeiten aktiviert

  Szenario: Aussehen einer Modell-Zeile
    Wenn man eine Modell-Zeile sieht
    Dann enthält die Modell-Zeile folgende Informationen:
    | information              |
    | Bild                     |
    | Name des Modells         |
    | Anzahl verfügbar (jetzt) |
    | Anzahl verfügbar (Total) |

  Szenario: Aussehen einer Gegenstands-Zeile
    Wenn man eine Gegenstands-Zeile sieht
    Dann enthält die Gegenstands-Zeile folgende Informationen:
    | information         |
    | Inventarcode        |
    | Ort des Gegenstands |
    Wenn der Gegenstand an Lager ist und meine Abteilung für den Gegenstand verantwortlich ist
    Dann enthält die Gegenstands-Zeile folgende Informationen:
    | information      |
    | Gebäudeabkürzung |
    | Raum             |
    | Gestell          |
    Wenn der Gegenstand nicht an Lager ist und meine Abteilung für den Gegenstand verantwortlich ist
    | information            |
    | Aktueller Ausleihender |
    | Enddatum der Ausleihe  |
    Wenn der Gegenstand nicht an Lager ist und meine Abteilung Besitzer des Gegenstands ist
    | information               |
    | Verantwortliche Abteilung |
    | Gebäudeabkürzung          |
    | Raum                      |

  Szenario: Aussehen einer Options-Zeile
    Wenn man eine Options-Zeile sieht
    Dann enthält die Options-Zeile folgende Informationen
    | information |
    | Barcode     |
    | Name        |
    | Preis       |

  Szenario: Modell aufklappen
    Wenn man eine Liste von Inventar sieht
    Dann kann man jedes Modell aufklappen
    Und man sieht die Gegenstände, die zum Modell gehören
    Und so eine Zeile sieht aus wie eine Gegenstands-Zeile

  Szenario: Paket-Modelle aufklappen
    Wenn man eine Liste von Inventar sieht
    Dann kann man jedes Paket-Modell aufklappen
    Und man sieht die Pakete dieses Paket-Modells
    Und so eine Zeile sieht aus wie eine Gegenstands-Zeile
    Und man kann diese Paket-Zeile aufklappen
    Und man sieht die Bestandteile, die zum Paket gehören
    Und so eine Zeile zeigt nur noch Inventarcode und Modellname des Bestandteils


  Szenario: Export der aktuellen Ansicht als CSV
    Wenn man eine Liste von Inventar sieht
    Dann kann man diese Daten als CSV-Datei exportieren
    Und die Datei enthält die gleichen Zeilen, wie gerade angezeigt werden (inkl. Filter)

  Szenario: Felder, die in der CSV-Datei exportiert werden
    Wenn ich eine CSV-Datei exportiere
    Dann enthält sie die folgenden Spalten:
    | spalte |
    |        |
