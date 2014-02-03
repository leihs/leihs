# language: de

Funktionalität: Gruppen

  Um Benutzer in Gruppen zu organisieren und Gruppen Modell-Kapazitäten zuzuteilen
  möchte ich als Ausleih-Verwalter
  vom System Funktionalitäten bereitgestellt bekommen

  Grundlage:
    Angenommen Personas existieren
    Und ich bin Pius

  @javascript
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

  @javascript
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

  @javascript
  Szenario: Noch nicht zugeteilten Kapazitäten
    Angenommen ich befinde mich im Admin-Bereich im Reiter Gruppen
    Wenn ich eine Gruppe erstelle
    Und die Modelle und deren Kapazität hinzufüge
    Dann sehe ich die noch nicht zugeteilten Kapazitäten

  @javascript
  Szenario: Gruppe löschen
    Angenommen ich befinde mich im Admin-Bereich im Reiter Gruppen
    Wenn ich eine Gruppe lösche
    Und die Gruppe wurde aus der Liste gelöscht
    Und die Gruppe wurde aus der Datenbank gelöscht
    
