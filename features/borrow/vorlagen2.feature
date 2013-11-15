# language: de

Funktionalität: Vorlagen

  Grundlage:
    Angenommen man ist "Normin"
    
  @javascript
  Szenario: Verfügbarkeitsansicht der Vorlage
    Angenommen ich sehe die Verfügbarkeit einer Vorlage, die nicht verfügbare Modelle enthält
    Dann sind diejenigen Modelle hervorgehoben, die zu diesem Zeitpunkt nicht verfügbar sind
    Und die Modelle sind innerhalb eine Gruppe alphabetisch sortiert
    Und ich kann Modelle aus der Ansicht entfernen
    Und ich kann die Anzahl der Modelle ändern
    Und ich kann das Zeitfenster für die Verfügbarkeitsberechnung einzelner Modelle ändern
    Wenn ich sämtliche Verfügbarkeitsprobleme gelöst habe
    Dann kann ich im Prozess weiterfahren und alle Modelle gesamthaft zu einer Bestellung hinzufügen

  @javascript
  Szenario: Nur verfügbaren Modelle aus Vorlage in Bestellung übernehmen
    Angenommen ich sehe die Verfügbarkeit einer nicht verfügbaren Vorlage
    Und einige Modelle sind nicht verfügbar
    Dann kann ich diejenigen Modelle, die verfügbar sind, gesamthaft einer Bestellung hinzufügen
    Und die restlichen Modelle werden verworfen
