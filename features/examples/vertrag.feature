# language: de

Funktionalität: Vertrag

  Um eine Aushändigung durchzuführen/zu dokumentieren
  möchte ich als Verleiher
  das mir das System einen Vertrag bereitstellen kann

  Grundlage:
    Angenommen ich bin Pius

  @javascript @firefox
  Szenario: Was ich auf dem Vertrag sehen möchte
    Angenommen man öffnet einen Vertrag bei der Aushändigung
    Dann möchte ich die folgenden Bereiche sehen:
    | Bereich                       |
    | Datum                         |
    | Titel                         |
    | Ausleihender                  |
    | Verleier                      |
    | Liste 1                       |
    | Liste 2                       |
    | Liste der Zwecke              |
    | Zusätzliche Notiz             |
    | Hinweis auf AGB               |
    | Unterschrift des Ausleihenden |
    | Seitennummer                  |
    | Barcode                       |
    | Vertragsnummer                |
    Und die Modelle sind innerhalb ihrer Gruppe alphabetisch sortiert

  @javascript @firefox
  Szenario: Hinweis auf AGB
    Angenommen man öffnet einen Vertrag bei der Aushändigung
    Dann seh ich den Hinweis auf AGB "Es gelten die Ausleih- und Benutzungsreglemente des Verleihers."

  @javascript @firefox
  Szenario: Welche Informationen ich vom Ausleihenden sehen möchte
    Angenommen man öffnet einen Vertrag bei der Aushändigung
    Dann möchte ich im Feld des Ausleihenden die folgenden Bereiche sehen:
    | Bereich      |
    | Vorname      |
    | Nachname     |
    | Strasse      |
    | Hausnummer   |
    | Länderkürzel |
    | PLZ          |
    | Stadt        |

  @javascript @firefox
  Szenario: Liste der zurückgebenen Gegenstände
    Angenommen man öffnet einen Vertrag bei der Aushändigung
    Wenn es Gegenstände gibt, die zurückgegeben wurden
    Dann sehe ich die Liste 1 mit dem Titel "Zurückgegebene Gegenstände"
    Und diese Liste enthält Gegenstände die ausgeliehen und zurückgegeben wurden

  @javascript @firefox
  Szenario: Zwecke
    Angenommen man öffnet einen Vertrag bei der Aushändigung
    Dann sehe ich eine Liste Zwecken, getrennt durch Kommas
     Und jeder identische Zweck ist maximal einmal aufgelistet

  @javascript @firefox
  Szenario: Datum
    Angenommen man öffnet einen Vertrag bei der Aushändigung
    Dann sehe ich das heutige Datum oben rechts

  @javascript @firefox
  Szenario: Titel
    Angenommen man öffnet einen Vertrag bei der Aushändigung
    Dann sehe ich den Titel im Format "Leihvertrag Nr. #"

  @javascript @firefox
  Szenario: Position des Barcodes
    Angenommen man öffnet einen Vertrag bei der Aushändigung
    Dann sehe ich den Barcode oben links

  @javascript @firefox
  Szenario: Position des Ausleihenden
    Angenommen man öffnet einen Vertrag bei der Aushändigung
    Dann sehe ich den Ausleihenden oben links

  @javascript @firefox
  Szenario: Inhalt der Liste 1 und Liste 2
    Angenommen man öffnet einen Vertrag bei der Aushändigung
    Dann beinhalten Liste 1 und Liste 2 folgende Spalten:
    | Spaltenname   |
    | Anzahl        |
    | Inventarcode  |
    | Modellname    |
    | Enddatum      |
    | Rückgabedatum / Rücknehmende Person |

  @javascript @firefox
  Szenario: Rücknehmende Person
    Angenommen man öffnet einen Vertrag bei der Rücknahme
    Dann sieht man bei den betroffenen Linien die rücknehmende Person im Format "V. Nachname"

  @javascript @firefox
  Szenario: Verleiher
    Angenommen man öffnet einen Vertrag bei der Aushändigung
    Dann sehe ich den Verleiher neben dem Ausleihenden

  @javascript @firefox
  Szenario: Liste der ausgeliehenen Gegenstände
    Angenommen man öffnet einen Vertrag bei der Aushändigung
    Wenn es Gegenstände gibt, die noch nicht zurückgegeben wurden
    Dann sehe ich die Liste 2 mit dem Titel "Ausgeliehene Gegenstände"
    Und diese Liste enthält Gegenstände, die ausgeliehen und noch nicht zurückgegeben wurden

  @javascript @firefox
  Szenario: Adresse des Verleihers aufführen
    Angenommen man öffnet einen Vertrag bei der Aushändigung
    Dann wird unter 'Verleiher/in' der Gerätepark aufgeführt
    Wenn in den globalen Einstellungen die Adresse der Instanz konfiguriert ist
    Dann wird unter dem Verleiher diese Adresse angezeigt


  Szenario: Adresse des Kunden ohne abschliessenden ", " anzeigen
    Angenommen es gibt einen Kunden mit Vertrag wessen Addresse mit ", " endet
    Wenn ich einen Vertrag dieses Kunden öffne
    Dann wird seine Adresse ohne den abschliessenden ", " angezeigt
