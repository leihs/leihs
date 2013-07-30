# language: de

Funktionalität: Vorlagen

  Szenario: Liste der Vorlagen finden
    Angenommen ich bin auf der Startseite
    Dann sehe ich unterhalb der Kategorien einen Link zur Liste der Vorlagen

  Szenario: Liste der Vorlagen
    Angenommen ich schaue mir die Liste der Vorlagen an
    Dann sehe ich die Vorlagen
    Und ich kann eine der Vorlagen detailliert betrachten

  Szenario: Betrachten einer Vorlage
    Angenommen ich sehe mir eine Vorlage an
    Dann sehe ich alle Modelle, die diese Vorlage beinhaltet
    Und ich sehe für jedes Modell die Anzahl Gegenstände dieses Modells, welche die Vorlage vorgibt
    Und ich kann die Anzahl jedes Modells verändern, bevor ich den Prozess fortsetze

  Szenario: Warnung bei nicht erfüllbaren Vorlagen
    Angenommen ich sehe mir eine Vorlage an
    Und in dieser Vorlage hat es Modelle, die nicht genügeng Gegenstände haben, um die in der Vorlage gewünschte Anzahl zu erfüllen
    Dann sehe ich eine auffällige Warnung sowohl auf der Seite wie bei den betroffenen Modellen

  Szenario: Datumseingabe bei Auswahl der Vorlage
    Angenommen ich sehe mir eine Vorlage an
    Dann kann ich Start- und Enddatum einer potenziellen Bestellung angeben
    Und ich kann im Prozess weiterfahren zur Verfügbarkeitsanzeige der Vorlage
    
  Szenario: Verfügbarkeitsansicht der Vorlage
    Angenommen ich sehe die Verfügbarkeit einer Vorlage
    Dann sehe ich, welche Modelle zu diesem Zeitpunkt in der angegebenen Anzahl verfügbar sind
    Und diejenigen Modelle sind hervorgehoben, die zu diesem Zeitpunkt nicht verfügbar sind
    Und ich kann Modelle aus der Ansicht entfernen
    Und ich kann die Anzahl der Modelle ändern
    Und ich kann das Zeitfenster für die Verfügbarkeitsberechnung einzelner Modelle ändern
    Wenn ich sämtliche Verfügbarkeitsprobleme gelöst habe
    Dann kann ich im Prozess weiterfahren und alle Modelle gesamthaft zu einer Bestellung hinzufügen

  Szenario: Nur verfügbarben Modelle aus Vorlage in Bestellung übernehmen
    Angenommen ich sehe die Verfügbarkeit einer Vorlage
    Und einige Modelle sind nicht verfügbar
    Dann kann ich diejenigen Modelle, die verfügbar sind, gesamthaft einer Bestellung hinzufügen
    Und die restlichen Modelle werden verworfen
