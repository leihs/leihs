# language: de

Funktionalität: Gruppen

  Um Benutzer in Gruppen zu organisieren und Gruppen Modell-Kapazitäten zuzuteilen
  möchte ich als Ausleih-Verwalter
  vom System Funktionalitäten bereitgestellt bekommen

  Grundlage:
    Angenommen ich bin Pius

  @personas
  Szenario: Anzeige der Gruppenliste
    Angenommen ich befinde mich im Admin-Bereich im Reiter Gruppen
    Dann sehe ich die Liste der Gruppen
    Und die Anzahl zugeteilter Benutzer
    Und die Anzahl der zugeteilten Modell-Kapazitäten

  @personas
  Szenario: Visierungspflichtige Gruppe erstellen
    Angenommen ich befinde mich im Admin-Bereich im Reiter Gruppen
    Wenn ich eine Gruppe erstelle
    Und ich die Eigenschaft 'Visierung erforderlich' anwähle
    Und den Namen der Gruppe angebe
    Und die Benutzer hinzufüge
    Und die Modelle und deren Kapazität hinzufüge
    Und ich speichere
    Dann ist die Gruppe gespeichert
    Und die Gruppe ist visierungspflichtig
    Und die Benutzer und Modelle mit deren Kapazitäten sind zugeteilt
    Und ich sehe die Gruppenliste alphabetisch sortiert
    Und ich sehe eine Bestätigung

  @personas
  Szenario: Gruppe editieren und als visierungspflichtig kennzeichnen
    Angenommen ich befinde mich im Admin-Bereich im Reiter Gruppen
    Wenn ich eine bestehende, nicht visierungspflichtige Gruppe editiere
    Und ich die Eigenschaft 'Visierung erforderlich' anwähle
    Und ich den Namen der Gruppe ändere
    Und die Benutzer hinzufüge und entferne
    Und die Modelle und deren Kapazität hinzufüge und entferne
    Und ich speichere
    Dann ist die Gruppe gespeichert
    Und die Gruppe ist visierungspflichtig
    Und die Benutzer und Modelle mit deren Kapazitäten sind zugeteilt
    Und ich sehe die Gruppenliste
    Und ich sehe eine Bestätigung

  @personas
  Szenario: Gruppe ist nicht visierungspflichtig
    Angenommen ich befinde mich im Admin-Bereich im Reiter Gruppen
    Wenn ich eine bestehende visierungspflichtige Gruppe editiere
    Und ich die Eigenschaft 'Visierung erforderlich' abwähle
    Und ich den Namen der Gruppe ändere
    Und die Benutzer hinzufüge und entferne
    Und die Modelle und deren Kapazität hinzufüge und entferne
    Und ich speichere
    Dann ist die Gruppe gespeichert
    Und die Gruppe ist nicht mehr visierungspflichtig
    Und die Benutzer und Modelle mit deren Kapazitäten sind zugeteilt
    Und ich sehe die Gruppenliste
    Und ich sehe eine Bestätigung

  @javascript @personas
  Szenario: Noch nicht zugeteilten Kapazitäten
    Angenommen ich befinde mich im Admin-Bereich im Reiter Gruppen
    Wenn ich eine Gruppe erstelle
    Und die Modelle und deren Kapazität hinzufüge
    Dann sehe ich die noch nicht zugeteilten Kapazitäten

  @javascript @personas
  Szenario: Gruppe löschen
    Angenommen ich befinde mich im Admin-Bereich im Reiter Gruppen
    Wenn ich eine Gruppe lösche
    Und die Gruppe wurde aus der Liste gelöscht
    Und die Gruppe wurde aus der Datenbank gelöscht

  @javascript @personas
  Szenario: Benutzer hinzufügen
    Angenommen ich befinde mich im Admin-Bereich im Reiter Gruppen
    Und ich eine bestehende Gruppe editiere
    Wenn ich einen Benutzer hinzufüge
    Dann wird der Benutzer zuoberst in der Liste hinzugefügt

  @personas
  Szenario: Benutzer sortieren
    Angenommen ich befinde mich im Admin-Bereich im Reiter Gruppen
    Und ich eine bestehende Gruppe editiere
    Dann sind die bereits hinzugefügten Benutzer alphabetisch sortiert

  @javascript @personas
  Szenario: Modelle hinzufügen
    Angenommen ich befinde mich im Admin-Bereich im Reiter Gruppen
    Und ich eine bestehende Gruppe editiere
    Wenn ich ein Modell hinzufüge
    Dann wird das Modell zuoberst in der Liste hinzugefügt

  @personas
  Szenario: Modelle sortieren
    Angenommen ich befinde mich im Admin-Bereich im Reiter Gruppen
    Und ich eine bestehende Gruppe editiere
    Dann sind die bereits hinzugefügten Modelle alphabetisch sortiert

  @javascript @personas
  Szenario: Modelle hinzufügen
    Angenommen ich befinde mich im Admin-Bereich im Reiter Gruppen
    Und ich eine bestehende Gruppe editiere
    Wenn ich ein Modell hinzufüge
    Dann wird das Modell zuoberst in der Liste hinzugefügt

  @personas
  Szenario: Modelle sortieren
    Angenommen ich befinde mich im Admin-Bereich im Reiter Gruppen
    Und ich eine bestehende Gruppe editiere
    Dann sind die bereits hinzugefügten Modelle alphabetisch sortiert

  @javascript @personas
  Szenario: bereits bestehende Modelle hinzufügen
    Angenommen ich befinde mich im Admin-Bereich im Reiter Gruppen
    Und ich eine bestehende Gruppe editiere
    Wenn ich ein bereits hinzugefügtes Modell hinzufüge
    Dann wird das Modell nicht erneut hinzugefügt
    Und das vorhandene Modell ist nach oben gerutscht
    Und das vorhandene Modell behält die eingestellte Anzahl

  @javascript @personas
  Szenario: bereits bestehende Benutzer hinzufügen
    Angenommen ich befinde mich im Admin-Bereich im Reiter Gruppen
    Und ich eine bestehende Gruppe editiere
    Wenn ich einen bereits hinzugefügten Benutzer hinzufüge
    Dann wird der Benutzer nicht hinzugefügt
    Und der vorhandene Benutzer ist nach oben gerutscht

  @personas
  Szenario: Gruppenliste Sortierung
    Angenommen ich befinde mich im Admin-Bereich im Reiter Gruppen
    Dann sehe ich die Liste der Gruppen
    Und die Liste ist alphabetisch sortiert

  @javascript @personas
  Szenario: Gruppe erstellen
    Angenommen ich befinde mich im Admin-Bereich im Reiter Gruppen
    Wenn ich eine Gruppe erstelle
    Und den Namen der Gruppe angebe
    Und die Benutzer hinzufüge
    Und die Modelle und deren Kapazität hinzufüge
    Und ich speichere
    Dann ist die Gruppe gespeichert
    Und die Gruppe ist nicht visierungspflichtig
    Und die Benutzer und Modelle mit deren Kapazitäten sind zugeteilt
    Und ich sehe die Gruppenliste alphabetisch sortiert
    Und ich sehe eine Bestätigung
