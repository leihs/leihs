# language: de

Funktionalität: Inventar

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Mike"
    Und man öffnet die Liste des Inventars

  @javascript
  Szenario: Was man auf einer Liste sieht
    Dann sieht man Modelle
    Und man sieht Optionen
    Und man sieht Pakete

  @javascript
  Szenario: Auswahlmöglichkeiten
    Dann hat man folgende Auswahlmöglichkeiten die nicht kombinierbar sind
    | auswahlmöglichkeit |
    | Aktives Inventar   |
    | Ausleihbar         |
    | Nicht ausleihbar   |
    | Ausgemustert       |
    | Ungenutzte Modelle |

  @javascript
  Szenario: Filtermöglichkeiten von Listen
    Dann hat man folgende Filtermöglichkeiten
    | filtermöglichkeit         |
    | An Lager                  |
    | Besitzer bin ich          |
    | Verantwortliche Abteilung |
    | Defekt                    |
    | Unvollständig             |
    Und die Filter können kombiniert werden

  @javascript
  Szenario: Grundeinstellung der Listenansicht
    Dann ist die Auswahl "Aktives Inventar" aktiviert
    Und es sind keine Filtermöglichkeiten aktiviert
