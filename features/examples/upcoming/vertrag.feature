# language: de

Funktionalität: Vertrag

  Um eine Aushändigung durchzuführen/zu dokumentieren
  möchte ich als Verleiher
  das mir das System einen Vertrag bereitstellen kann

  Grundlage:
    Angenommen man ist "Pius"
    Und man öffnet einen Vertrag

  Szenario: Was ich auf dem Vertrag sehen möchte
    Dann möchte ich die folgenden Sachen sehen:
    | Sache                         |
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

  Szenario: Hinweis auf AGB
    Dann seh ich den Hinweis auf AGB "Es gelten die Ausleih- und Benutzungsreglemente des Verleihers."
     
  Szenario: Inhalt der Liste 1 und Liste 2
    Dann beinhalten Liste 1 und Liste 2 folgende Spalten:
    | Spaltenname   |
    | Anzahl        |
    | Inventarcode  |
    | Modellname    |
    | Startdatum    |
    | Enddatum      |
    | Rückgabedatum |
  
  Szenario: Zwecke
    Dann sehe ich eine Liste Zwecken, getrennt durch Kommas
    
  Szenario: Liste 1
    Wenn es Gegenstände gibt, die zurückgegeben wurden
    Dann sehe ich die Liste 1 mit dem Titel "Zurückgebene Gegenstände"
    Und diese Liste enthält Gegenstände die ausgeliehen und zurückgegeben wurden
  
  Szenario: Datum
    Dann sehe ich das heutige Datum oben rechts
  
  Szenario: Liste 2
    Wenn es Gegenstände gibt, die noch nicht zurückgegeben wurden
    Dann sehe ich die Liste 2 mit dem Titel "Ausgeliehene Gegenstände"
    Und diese Liste enthält Gegenstände, die ausgeliehen und noch nicht zurückgegeben wurden

  Szenario: Titel
    Dann sehe ich den Titel im Format "Leihvertrag Nr. #"
   
  Szenario: Position des Barcodes
    Dann sehe ich den Barcode unten rechts
    
  Szenario: Verleiher
    Dann sehe ich den Verleiher neben dem Ausleihenden
    
  Szenario: Position des Ausleihenden
    Dann sehe ich den Ausleihenden oben links
      
  Szenario: Welche Informationen ich vom Ausleihenden sehen möchte
    Dann möchte ich die folgenden Sachen sehen:
    | Sache        |
    | Vorname      |
    | Nachname     |
    | Strasse      |
    | Hausnummer   |
    | Länderkürzel |
    | PLZ          |
    | Stadt        |
   
  Szenario: Vertragsnummer unter dem Barcode
    Dann sehe ich die Vertragsnummer unter dem Barcode
    
  Szenario: Präfix für Barcode
    Dann hat der Barcode ein Präfix
    
  Szenario: Seitennummerierung
    Dann sehe ich auf jeder Seite die Seitennummerierung im Format "X / Y"
       
  Szenario: Strikte Trennung
    Dann sehe ich das bereits zurückgegebene Gegenstände getrennt sind von denen, die noch nicht zürückgegeben wurden.
  
