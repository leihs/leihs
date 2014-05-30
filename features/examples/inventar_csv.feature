# language: de

Funktionalität: Inventar


  Szenario: Globaler Export des Inventars aller Geräteparks
    Angenommen ich bin Gino
    Und man öffnet die Liste der Geräteparks
    Dann kann man das globale Inventar als CSV-Datei exportieren

  @javascript
  Szenario: Export der aktuellen Ansicht als CSV
    Angenommen ich bin Mike
    Und man öffnet die Liste des Inventars
    Dann kann man diese Daten als CSV-Datei exportieren
    Und die Datei enthält die gleichen Zeilen, wie gerade angezeigt werden (inkl. Filter)

  Szenario: Export der aktuellen Software-Ansicht als CSV
    Angenommen ich bin Mike
    Und man öffnet die Liste des Inventars
    Und ich befinde mich in der Software-Inventar-Übersicht
    Wenn ich den CSV-Export anwähle
    Dann werden alle Lizenz-Zeilen, wie gerade gemäss Filter angezeigt, exportiert
    Und die Zeilen enthalten alle Lizenz-Felder
