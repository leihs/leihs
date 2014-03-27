# language: de

Funktionalität: Vertrag

  Um eine Aushändigung durchzuführen/zu dokumentieren
  möchte ich als Verleiher
  das mir das System einen Vertrag bereitstellen kann

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Pius"

  @javascript
  Szenario: Verleiher
    Angenommen man öffnet einen Vertrag bei der Aushändigung
    Dann sehe ich den Verleiher neben dem Ausleihenden

  @javascript
  Szenario: Liste der ausgeliehenen Gegenstände
    Angenommen man öffnet einen Vertrag bei der Aushändigung
    Wenn es Gegenstände gibt, die noch nicht zurückgegeben wurden
    Dann sehe ich die Liste 2 mit dem Titel "Ausgeliehene Gegenstände"
    Und diese Liste enthält Gegenstände, die ausgeliehen und noch nicht zurückgegeben wurden

  @javascript
  Szenario: Adresse des Verleihers aufführen
    Angenommen man öffnet einen Vertrag bei der Aushändigung
    Dann wird unter 'Verleiher/in' der Gerätepark aufgeführt
    #Wenn in den Einstellungen die Adresse des Verleihers konfiguriert ist
    #Dann wird darunter die Adresse des Verleihers aufgeführt
