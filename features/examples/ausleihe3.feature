# language: de

Funktionalität: Ausleihe

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Pius"

  @javascript
  Szenario: Scanning-Verhalten beim Aushändigen
    Wenn ich eine Aushändigung mache mit einem Kunden der sowohl am heutigen Tag sowie in der Zukunft Abholungen hat
    Wenn ich etwas scanne (per Inventarcode zuweise) und es in irgendeinem zukünftigen Vertrag existiert
    Dann wird es zugewiesen (unabhängig ob es ausgewählt ist)
    Wenn es in keinem zukünftigen Vertrag existiert 
    Dann wird es für die ausgewählte Zeitspanne hinzugefügt

  @javascript
  Szenario: Inspektion bei Rücknahme
    Angenommen ich mache eine Rücknahme
    Dann habe ich für jeden Gegenstand die Möglichkeit, eine Inspektion auszulösen
    Wenn ich bei einem Gegenstand eine Inspektion durchführen
    Und die Inspektion erlaubt es, den Status von "Zustand" auf "Funktionstüchtig" oder "Defekt" zu setzen
    Und die Inspektion erlaubt es, den Status von "Vollständigkeit" auf "Vollständig" oder "Unvollständig" zu setzen
    Und die Inspektion erlaubt es, den Status von "Ausleihbar" auf "Ausleihbar" oder "Nicht ausleihbar" zu setzen
    Wenn ich Werte der Inspektion ändere
    Und wenn ich die Inspektion speichere
    Dann wird der Gegenstand mit den aktuell gesetzten Status gespeichert

  @javascript
  Szenario: Automatischer Druck Dialog beim Aushändigen
    Wenn ich eine Aushändigung mache
    Dann wird automatisch der Druck-Dialog geöffnet

  @javascript
  Szenario: Default des Start- und Enddatums
    Wenn ich eine Aushändigung mache
    Dann ist das Start- und Enddatum gemäss dem ersten Zeitfenster der Aushändigung gesetzt

  
  
  
