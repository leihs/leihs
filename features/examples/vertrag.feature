# language: de

Funktionalität: Vertrag

  Um eine Aushändigung durchzuführen/zu dokumentieren
  möchte ich als Verleiher
  das mir das System einen Vertrag bereitstellen kann

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Pius"
    Und man öffnet einen Vertrag
  
  @javascript
  Szenario: Was ich auf dem Vertrag sehen möchte
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

  @javascript
  Szenario: Hinweis auf AGB
    Dann seh ich den Hinweis auf AGB "Es gelten die Ausleih- und Benutzungsreglemente des Verleihers."
  
  @javascript   
  Szenario: Inhalt der Liste 1 und Liste 2
    Dann beinhalten Liste 1 und Liste 2 folgende Spalten:
    | Spaltenname   |
    | Anzahl        |
    | Inventarcode  |
    | Modellname    |
    | Startdatum    |
    | Enddatum      |
    | Rückgabedatum |
  
  @javascript
  Szenario: Zwecke
    Dann sehe ich eine Liste Zwecken, getrennt durch Kommas

  @javascript    
  Szenario: Datum
    Dann sehe ich das heutige Datum oben rechts
    
  @javascript
  Szenario: Titel
    Dann sehe ich den Titel im Format "Leihvertrag Nr. #"
  
  @javascript 
  Szenario: Position des Barcodes
    Dann sehe ich den Barcode oben links
  
  @javascript  
  Szenario: Position des Ausleihenden
    Dann sehe ich den Ausleihenden oben links
    
  @javascript 
  Szenario: Verleiher
    Dann sehe ich den Verleiher neben dem Ausleihenden
  
  @javascript
  Szenario: Welche Informationen ich vom Ausleihenden sehen möchte
    Dann möchte ich im Feld des Ausleihenden die folgenden Bereiche sehen:
    | Bereich      |
    | Vorname      |
    | Nachname     |
    | Strasse      |
    | Hausnummer   |
    | Länderkürzel |
    | PLZ          |
    | Stadt        |
    
  # Szenario: Vertragsnummer unter dem Barcode
  # Dann sehe ich die Vertragsnummer unter dem Barcode # Es liegt an den Browser Einstellungen ob die Vertragsnummer beim Druck auf jeder Seite wiederholt werden.  
    
  # Szenario: Seitennummerierung
  # Dann sehe ich auf jeder Seite die Seitennummerierung im Format "X / Y" # Es liegt an den Browser Einstellungen ob man beim Druck auf jeder Seite die Seitennummerierung sieht.
  
  @javascript
  Szenario: Liste der zurückgebenen Gegenstände
    Wenn es Gegenstände gibt, die zurückgegeben wurden
    Dann sehe ich die Liste 1 mit dem Titel "Zurückgegebene Gegenstände"
    Und diese Liste enthält Gegenstände die ausgeliehen und zurückgegeben wurden
  
  @javascript
  Szenario: Liste der ausgeliehenen Gegenstände
    Wenn es Gegenstände gibt, die noch nicht zurückgegeben wurden
    Dann sehe ich die Liste 2 mit dem Titel "Ausgeliehene Gegenstände"
    Und diese Liste enthält Gegenstände, die ausgeliehen und noch nicht zurückgegeben wurden

  @javascript
  Szenario: Automatischer Druck Dialog beim Aushändigen
    Wenn ich eine Aushändigung mache
    Dann wird automatisch der Druck-Dialog geöffnet

  @javascript
  Szenario: Adresse des Verleihers aufführen
    Dann wird die folgende Adresse bei 'Verleiher' aufgeführt:
    |Zürcher Hochschule der Künste|
    |Ausstellungsstrasse 60|
    |8005 Zürich|
