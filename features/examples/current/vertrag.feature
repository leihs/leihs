Feature: Vertrag

  Background:
    Wenn ich einen Vertrag öffne

  Scenario: Was ich auf dem Vertrag sehen möchte.
    Dann möchte ich die folgenden Sachen sehen:
    | Teil                          |
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

  Scenario: Hinweis auf AGB
    Dann seh ich den Hinweis auf AGB "Es gelten die Ausleih- und Benutzungsreglemente des Verleihers."
     
  Scenario: Inhalt der Liste 1 und Liste 2
    Dann beinhalten Liste 1 und Liste 2 folgende Spalten:
    | Spaltenname   |
    | Anzahl        |
    | Inventarcode  |
    | Modelname     |
    | Startdatum    |
    | Enddatum      |
    | Rückgabedatum |
  
  Scenario: Zwecke
    Dann seh ich eine Liste von komma-getrennten Zwecken
    
  Scenario: Liste 1
    Wenn es Gegenstände gibt die zurückgegeben wurden
    Dann sehe ich die Liste 1 mit dem Titel "Zurückgebene Gegenstände"
    Und diese Liste enthält gegenstehnde die ausgeliehen und zurückgegeben wurden
  
  Scenario: Datum
    Dann sehe ich das heuteig Datum oben rechts
  
  Scenario: Liste 2
    Wenn es Gegenstände gibt die noch nicht zurückgegeben wurden
    Dann sehe ich die Liste 2 mit dem Titel "Ausgeliehene Gegenstände"
    Und diese Liste enthält Gegenstände die ausgeliehen und noch nicht zurückgegeben wurden

  Scenario: Titel
    Dann seh ich den Titel im Format "Leihvertrag Nr. #"
   
  Scenario: Position des Barcodes
    Dann seh ich den Barcode unten rechts
    
  Scenario: Verleiher
    Dann seh ich den Verleiher neben dem Ausleihenden
    
  Scenario: Position des Ausleihenden
    Dann seh ich den Ausleihenden oben links
      
  Scenario: Welche Informationen ich vom Ausleihenden sehen möchte
    Dann möchte ich die folgenden Sachen sehen:
    | Information   |
    | Vorname       |
    | Nachname      |
    | Strasse       |
    | Hausnummer    |
    | Landerkürzel  |
    | PLZ           |
    | Stadt         |
   
  Scenario: Vertragsnummer unter dem Barcode
    Dann seh ich die Vertragsnummer unter dem Barcode
    
  Scenario: Prefix für Barcode
    Dann hat der Barcode einen Prefix
    
  Scenario: Seitennummerierung
    Dann seh ich auf jeder Seite die Seitennummerierung im Format "X / Y"
       
  Scenario: Strikte Trennung
    Dann seh ich das bereits zurückgegebene Gegenstände getrennt sind von den die noch nicht zürückgegeben wurden.
  
