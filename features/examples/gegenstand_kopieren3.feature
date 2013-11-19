# language: de

Funktionalität: Gegenstand kopieren

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Mike"

  @javascript
  Szenario: Gegenstand aus einem anderem Gerätepark kopieren
    Angenommen I go to logout
    Und man ist "Matti"
    Und man editiert ein Gegenstand eines anderen Besitzers
    Wenn man speichert und kopiert
    Dann wird eine neue Gegenstandskopieransicht geöffnet
    Und alle Felder sind editierbar, da man jetzt Besitzer von diesem Gegenstand ist

  @javascript
  Szenario: Neuen Lieferanten erstellen falls nicht vorhanden
    Angenommen man einen Gegenstand kopiert
    Dann wird eine neue Gegenstandskopieransicht geöffnet
    Wenn ich einen nicht existierenen Lieferanten angebe
    Und ich merke mir den Inventarcode für weitere Schritte
    Und ich speichern druecke
    Dann wird der neue Lieferant erstellt
    Und bei dem kopierten Gegestand ist der neue Lieferant eingetragen
