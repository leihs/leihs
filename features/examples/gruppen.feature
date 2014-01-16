# language: de

Funktionalität: Gruppen

  Um Benutzer in Gruppen zu organisieren und Gruppen Modell-Kapazitäten zuzuteilen
  möchte ich als Ausleih-Verwalter
  vom System Funktionalitäten bereitgestellt bekommen

  Grundlage:
    Angenommen Personas existieren
    Und ich bin Pius

  @javascript
  Szenario: Anzeige der Gruppenliste
    Angenommen ich befinde mich im Admin-Bereich im Reiter Gruppen
    Dann sehe ich die Liste der Gruppen
    Und die Anzahl zugeteilter Benutzer
    Und die Anzahl der zugeteilten Modell-Kapazitäten

  @javascript
  Szenario: Gruppenliste Sortierung
    Angenommen ich befinde mich im Admin-Bereich im Reiter Gruppen
    Dann sehe ich die Liste der Gruppen
    Und die Liste ist alphabetisch sortiert
  
  @javascript
  Szenario: Gruppe erstellen
    Angenommen ich befinde mich im Admin-Bereich im Reiter Gruppen
    Wenn ich eine Gruppe erstelle
    Und den Namen der Gruppe angebe
    Und die Benutzer hinzufüge
    Und die Modelle und deren Kapazität hinzufüge
    Und ich speichere
    Dann ist die Gruppe gespeichert
    Und die Benutzer und Modelle mit deren Kapazitäten sind zugeteilt
    Und ich sehe die Gruppenliste alphabetisch sortiert
    Und ich sehe eine Bestätigung
