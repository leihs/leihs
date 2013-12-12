# language: de

Funktionalität: Inventar

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Gino"
    Und man öffnet die Liste der Geräteparks

  @javascript
  Szenario: Globaler Export des Inventars aller Geräteparks
    Dann kann man das globale Inventar als CSV-Datei exportieren
