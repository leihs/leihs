# language: de

Funktionalität: Gruppen

  Um Benutzer in Gruppen zu organisieren und Gruppen Modell-Kapazitäten zuzuteilen
  möchte ich als Ausleih-Verwalter
  vom System Funktionalitäten bereitgestellt bekommen

  @javascript
  Szenario: Modelle hinzufügen
    Angenommen ich befinde mich im Admin-Bereich im Reiter Gruppen
    Und ich eine bestehende Gruppe editiere
    Wenn ich ein Modell hinzufüge
    Dann wird das Modell zuoberst in der Liste hinzugefügt
    
  Szenario: Modelle sortieren
    Angenommen ich befinde mich im Admin-Bereich im Reiter Gruppen
    Und ich eine bestehende Gruppe editiere
    Dann sind die bereits hinzugefügten Modelle alphabetisch sortiert
    
  @javascript
  Szenario: bereits bestehende Modelle hinzufügen
    Angenommen ich befinde mich im Admin-Bereich im Reiter Gruppen
    Und ich eine bestehende Gruppe editiere
    Wenn ich ein bereits hinzugefügtes Modell hinzufüge
    Dann wird das Modell nicht erneut hinzugefügt
    Und das vorhandene Modell ist nach oben gerutscht
    Und das vorhandene Modell behält die eingestellte Anzahl
    
  @javascript
  Szenario: bereits bestehende Benutzer hinzufügen
    Angenommen ich befinde mich im Admin-Bereich im Reiter Gruppen
    Und ich eine bestehende Gruppe editiere
    Wenn ich einen bereits hinzugefügten Benutzer hinzufüge
    Dann wird der Benutzer nicht hinzugefügt
    Und der vorhandene Benutzer ist nach oben gerutscht
