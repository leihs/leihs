# language: de

Funktionalität: Vertrag

  Um eine Aushändigung durchzuführen/zu dokumentieren
  möchte ich als Verleiher
  das mir das System einen Vertrag bereitstellen kann

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Pius"

  @javascript
  Szenario: Zwecke
    Angenommen man öffnet einen Vertrag bei der Aushändigung
    Dann sehe ich eine Liste Zwecken, getrennt durch Kommas
     Und jeder identische Zweck ist maximal einmal aufgelistet

  @javascript    
  Szenario: Datum
    Angenommen man öffnet einen Vertrag bei der Aushändigung
    Dann sehe ich das heutige Datum oben rechts
    
  @javascript
  Szenario: Titel
    Angenommen man öffnet einen Vertrag bei der Aushändigung
    Dann sehe ich den Titel im Format "Leihvertrag Nr. #"
  
  @javascript 
  Szenario: Position des Barcodes
    Angenommen man öffnet einen Vertrag bei der Aushändigung
    Dann sehe ich den Barcode oben links
  
  @javascript  
  Szenario: Position des Ausleihenden
    Angenommen man öffnet einen Vertrag bei der Aushändigung
    Dann sehe ich den Ausleihenden oben links