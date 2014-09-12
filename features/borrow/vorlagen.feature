# language: de

Funktionalität: Vorlagen

  Grundlage:
    Angenommen ich bin Normin

  @personas
  Szenario: Liste der Vorlagen finden
    Angenommen man befindet sich auf der Seite der Hauptkategorien
    Dann sehe ich unterhalb der Kategorien einen Link zur Liste der Vorlagen

  @personas
  Szenario: Liste der Vorlagen
    Angenommen ich schaue mir die Liste der Vorlagen an
    Dann sehe ich die Vorlagen
    Und die Vorlagen sind alphabetisch nach Namen sortiert
    Und ich kann eine der Vorlagen detailliert betrachten

  @javascript @browser @personas
  Szenario: Betrachten einer Vorlage
    Angenommen ich sehe mir eine Vorlage an
    Dann sehe ich alle Modelle, die diese Vorlage beinhaltet
    Und die Modelle in dieser Vorlage sind alphabetisch sortiert
    Und ich sehe für jedes Modell die Anzahl Gegenstände dieses Modells, welche die Vorlage vorgibt
    Und ich kann die Anzahl jedes Modells verändern, bevor ich den Prozess fortsetze
    Und ich kann höchstens die maximale Anzahl an verfügbaren Geräten eingeben
    Und ich muss den Prozess zur Datumseingabe fortsetzen

  @personas
  Szenario: Warnung bei nicht erfüllbaren Vorlagen
    Angenommen ich sehe mir eine Vorlage an
    Und in dieser Vorlage hat es Modelle, die nicht genügeng Gegenstände haben, um die in der Vorlage gewünschte Anzahl zu erfüllen
    Dann sehe ich eine auffällige Warnung sowohl auf der Seite wie bei den betroffenen Modellen

  @javascript @personas
  Szenario: Datumseingabe nach Mengenangabe
    Angenommen ich habe die Mengen in der Vorlage gewählt
    Dann ist das Startdatum heute und das Enddatum morgen 
    Und ich kann das Start- und Enddatum einer potenziellen Bestellung ändern
    Und ich muss im Prozess weiterfahren zur Verfügbarkeitsanzeige der Vorlage
    Und alle Einträge erhalten das ausgewählte Start- und Enddatum

  @javascript @browser @personas
  Szenario: Verfügbarkeitsansicht der Vorlage
    Angenommen ich sehe die Verfügbarkeit einer Vorlage, die nicht verfügbare Modelle enthält
    Dann sind diejenigen Modelle hervorgehoben, die zu diesem Zeitpunkt nicht verfügbar sind
    Und die Modelle sind innerhalb eine Gruppe alphabetisch sortiert
    Und ich kann Modelle aus der Ansicht entfernen
    Und ich kann die Anzahl der Modelle ändern
    Und ich kann das Zeitfenster für die Verfügbarkeitsberechnung einzelner Modelle ändern
    Wenn ich sämtliche Verfügbarkeitsprobleme gelöst habe
    Dann kann ich im Prozess weiterfahren und alle Modelle gesamthaft zu einer Bestellung hinzufügen

  @personas
  Szenario: Nur verfügbaren Modelle aus Vorlage in Bestellung übernehmen
    Angenommen ich sehe die Verfügbarkeit einer nicht verfügbaren Vorlage
    Und einige Modelle sind nicht verfügbar
    Dann kann ich diejenigen Modelle, die verfügbar sind, gesamthaft einer Bestellung hinzufügen
    Und die restlichen Modelle werden verworfen
