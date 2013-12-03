# language: de

Funktionalität: Modellübersicht

  Um ausführliche Informationen über ein Modell zu erhalten
  möchte ich als Ausleihender
  die Möglichkeit haben ausführliche Informationen über ein Modell zu sehen
  
  @javascript
  Szenario: Bilder vergrössern
    Angenommen man ist "Normin"
    Und man befindet sich in einer Modellübersicht mit Bildern
    Wenn ich über ein solches Bild hovere
    Dann wird das Bild zum Hauptbild
    Wenn ich über ein weiteres Bild hovere
    Dann wird dieses zum Hauptbild
    Wenn ich ein Bild anklicke
    Dann wird das Bild zum Hauptbild auch wenn ich das hovern beende

  @javascript
  Szenario: Eigenschaften anzeigen
    Angenommen man ist "Normin"
    Und man befindet sich in einer Modellübersicht mit Eigenschaften
    Dann werden die ersten fünf Eigenschaften mit Schlüssel und Wert angezeigt
    Und wenn man 'Alle Eigenschaften anzeigen' wählt
    Dann werden alle weiteren Eigenschaften angezeigt
    Und man kann an derselben Stelle die Eigenschaften wieder zuklappen
