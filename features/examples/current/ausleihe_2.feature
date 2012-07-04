# language: de

Funktionalität: Ausleihe II

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Pius"
    
    @javascript
    Szenario: Alle Suchresultate anzeigen
      Angenommen ich suche
      Dann erhalte ich Suchresultate in den Kategorien Benutzer, Modelle, Gegenstände, Verträge
      Und ich sehe aus jeder Kategorie maximal die 3 ersten Resultate
      Wenn eine Kategorie mehr als 3 Resultate bringt
      Dann kann ich wählen, ob ich aus einer Kategorie mehr Resultate sehen will
      Wenn ich mehr Resultate wähle
      Dann sehe ich die ersten 10 Resultate
      Wenn die Kategorie mehr als 10 Resultate bringt
      Dann kann ich wählen, ob ich alle Resultate sehen will
      Wenn ich alle Resultate wähle
      Dann erhalte ich eine separate Liste aller Resultate dieser Kategorie

    @javascript
    Szenario: Zusammenziehen der Anzahlen im Item-Popup
      Angenommen man fährt über die Anzahl von Gegenständen in einer Zeile
      Dann werden alle diese Gegenstände aufgelistet
      Und man sieht pro Modell eine Zeile
      Und man sieht auf jeder Zeile die Summe der Gegenstände des jeweiligen Modells

    @javascript
    Szenario: Information über die Anzahl der verfügbaren/nicht verfügbaren Modelle
      Angenommen ich sehe Probleme auf einer Zeile, die durch die Verfügbarkeit bedingt sind
      Und ich fahre über das Problem
      Dann sehe ich den Grund für das Problem in der folgenden Form: "Dieses Modell ist nicht verfügbar (5 sind reserviert, 4 sind verfügbar: -1)"
      Und ich sehe die Anzahl der reservierten Modelle
      Und ich sehe die Anzahl der verfügbaren Modelle
      Und ich sehe die Summe der Anzahl der reservierten und verfügbaren Modelle

    @javascript
    Szenario: Inspektion bei Rücknahme
      Angenommen ich mache eine Rücknahme
      Dann habe ich für jeden Gegenstand die Möglichkeit, eine Inspektion auszulösen
      Und die Inspektion erlaubt es, den Status von "Zustand" auf "Funktionstüchtig" oder "Defekt" zu setzen
      Und die Inspektion erlaubt es, den Status von "Vollständigkeit" auf "Vollständig" oder "Unvollständig" zu setzen
      Und die Inspektion erlaubt es, den Status von "Ausleihbar" auf "Ausleihbar" oder "Nicht ausleihbar" zu setzen
      Und wenn ich die Inspektion speichere
      Dann wird der Gegenstand mit den aktuell gesetzten Status gespeichert
      