# language: de

Funktionalität: Inventar

  Grundlage:
    Angenommen ich bin Mike
    Und man öffnet die Liste des Inventars

  @javascript @personas
  Szenario: Was man auf einer Liste sieht
    Dann sieht man Modelle
    Und man sieht Optionen
    Und man sieht Pakete
    Wenn ich mich auf der Softwareliste befinde
    Dann man sieht Software

  @javascript @personas
  Szenario: Auswahlmöglichkeiten
    Dann hat man folgende Auswahlmöglichkeiten die nicht kombinierbar sind
    | auswahlmöglichkeit |
    | Aktives Inventar   |
    | Ausleihbar         |
    | Nicht ausleihbar   |
    | Ausgemustert       |
    | Ungenutzte Modelle |
    | Software           |

  @javascript @personas
  Szenario: Aussehen einer Options-Zeile
    Dann enthält die Options-Zeile folgende Informationen
    | information |
    | Barcode     |
    | Name        |
    | Preis       |

  @javascript @personas
  Szenario: Keine Leeren Modelle auf der Liste des Inventars
    Dann sieht man keine Modelle, denen keine Gegenstänge zugewiesen unter keinem der vorhandenen Reiter

  @javascript @personas
  Szenario: Paket-Modelle aufklappen
    Dann kann man jedes Paket-Modell aufklappen
    Und man sieht die Pakete dieses Paket-Modells
    Und so eine Zeile sieht aus wie eine Gegenstands-Zeile
    Und man kann diese Paket-Zeile aufklappen
    Und man sieht die Bestandteile, die zum Paket gehören
    Und so eine Zeile zeigt nur noch Inventarcode und Modellname des Bestandteils

  @javascript @personas
  Szenario: Aussehen einer Modell-Zeile
    Wenn man eine Modell-Zeile sieht
    Dann enthält die Modell-Zeile folgende Informationen:
    | information              |
    | Bild                     |
    | Name des Modells         |
    | Anzahl verfügbar (jetzt) |
    | Anzahl verfügbar (Total) |

  @javascript @personas
  Szenario: Aussehen einer Gegenstands-Zeile
    Wenn der Gegenstand an Lager ist und meine Abteilung für den Gegenstand verantwortlich ist
    Dann enthält die Gegenstands-Zeile folgende Informationen:
    | information      |
    | Gebäudeabkürzung |
    | Raum             |
    | Gestell          |
    Wenn meine Abteilung Besitzer des Gegenstands ist die Verantwortung aber auf eine andere Abteilung abgetreten hat
    Dann enthält die Gegenstands-Zeile folgende Informationen:
    | information               |
    | Verantwortliche Abteilung |
    | Gebäudeabkürzung          |
    | Raum                      |
    Wenn der Gegenstand nicht an Lager ist und eine andere Abteilung für den Gegenstand verantwortlich ist
    Dann enthält die Gegenstands-Zeile folgende Informationen:
    | information            |
    | Verantwortliche Abteilung |
    | Aktueller Ausleihender |
    | Enddatum der Ausleihe  |

  #73278560
  @current
  Szenario: Aussehen einer Software-Lizenz-Zeile
    Wenn eine Software-Lizenz-Zeile angezeigt wird
    Dann enthält die Software-Lizenz-Zeile folgende Informationen:
      | information    |
      | Betriebssystem |
      | Lizenztyp      |
    Wenn die Software-Lizenz den Lizenztyp "Konkurrent", "Site-Lizenz" oder "Mehrplatz" hat
    Dann enthält die Software-Lizenz-Zeile folgende Informationen:
      | information    |
      | Anzahl         |
      | Betriebssystem |
      | Lizenztyp      |
    Wenn meine Abteilung Besitzer der Software-Lizenz ist, die Verantwortung aber auf eine andere Abteilung abgetreten hat
    Dann enthält die Software-Lizenz-Zeile folgende Informationen:
      | information               |
      | Verantwortliche Abteilung |
      | Betriebssystem            |
      | Lizenztyp                 |
    Wenn die Software-Lizenz nicht an Lager ist und eine andere Abteilung für die Software-Lizenz verantwortlich ist
    Dann enthält die Software-Lizenz-Zeile folgende Informationen:
      | information            |
      | Verantwortliche Abteilung |
      | Betriebssystem            |
      | Lizenztyp                 |
      | Aktueller Ausleihender |
      | Enddatum der Ausleihe  |


  @javascript @personas
  Szenario: Keine Resultate auf der Liste des Inventars
    Wenn ich eine resultatlose Suche mache
    Dann sehe ich "Kein Eintrag gefunden"

  @javascript @personas
  Szenario: Modell aufklappen
    Dann kann man jedes Modell aufklappen
    Und man sieht die Gegenstände, die zum Modell gehören
    Und so eine Zeile sieht aus wie eine Gegenstands-Zeile

  @javascript @personas
  Szenario: Filtermöglichkeiten von Listen
    Dann hat man folgende Filtermöglichkeiten
    | filtermöglichkeit         |
    | An Lager                  |
    | Besitzer bin ich          |
    | Verantwortliche Abteilung |
    | Defekt                    |
    | Unvollständig             |
    Und die Filter können kombiniert werden

  @personas
  Szenario: Grundeinstellung der Listenansicht
    Dann ist die Auswahl "Aktives Inventar" aktiviert
    Und es sind keine Filtermöglichkeiten aktiviert
