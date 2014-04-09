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
    Wenn in den globalen Einstellungen die Adresse der Instanz konfiguriert ist
    Dann wird unter dem Verleiher diese Adresse angezeigt

  @javascript
  Szenario: Adresse des Kunden ohne abschliessenden ", " anzeigen
    Angenommen es gibt einen Kunden mit Vertrag wessen Addresse mit ", " endet
    Wenn ich einen Vertrag dieses Kunden öffne
    Dann wird seine Adresse ohne den abschliessenden ", " angezeigt
