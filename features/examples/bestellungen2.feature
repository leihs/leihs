# language: de

Funktionalität: Bestellungen

  @javascript
  Szenario: Reiter "Genehmigt" Darstellung
    Angenommen ich bin Andi
    Und ich befinde mich im Gerätepark mit visierpflichtigen Bestellungen
    Und ich mich auf der Liste der Bestellungen befinde
    Wenn ich den Reiter "Genehmigt" einsehe
    Dann sehe ich alle genehmigten visierpflichtigen Bestellungen
    Und ich sehe auf der Bestellungszeile den Besteller mit Popup-Ansicht der Benutzerinformationen
    Und ich sehe auf der Bestellungszeile das Erstelldatum
    Und ich sehe auf der Bestellungszeile die Anzahl Gegenstände mit Popup-Ansicht der bestellten Gegenstände
    Und ich sehe auf der Bestellungszeile die Dauer der Bestellung
    Und ich sehe auf der Bestellungszeile den Status
    Und ich eine bereits gehmigte Bestellung editiere
    Und gelange ich in die Ansicht der Aushändigung
    Aber ich kann nicht aushändigen

  @javascript
  Szenario: Reiter "Abgelehnt" Darstellung
    Angenommen ich bin Andi
    Und ich befinde mich im Gerätepark mit visierpflichtigen Bestellungen
    Und ich mich auf der Liste der Bestellungen befinde
    Wenn ich den Reiter "Abgelehnt" einsehe
    Dann sehe ich alle abgelehnten visierpflichtigen Bestellungen
    Und ich sehe auf der Bestellungszeile den Besteller mit Popup-Ansicht der Benutzerinformationen
    Und ich sehe auf der Bestellungszeile das Erstelldatum
    Und ich sehe auf der Bestellungszeile die Anzahl Gegenstände mit Popup-Ansicht der bestellten Gegenstände
    Und ich sehe auf der Bestellungszeile die Dauer der Bestellung
    Und ich sehe auf der Bestellungszeile den Status

  @javascript
  Szenario: Filter zum visieren aufheben
    Angenommen ich bin Andi
    Und ich befinde mich im Gerätepark mit visierpflichtigen Bestellungen
    Und ich mich auf der Liste der Bestellungen befinde
    Und sehe ich alle visierpflichtigen Bestellungen
    Wenn ich den Filter "Zu prüfen" aufhebe
    Dann sehe ich alle Bestellungen, welche von Benutzern der visierpflichtigen Gruppen erstellt wurden

  @javascript
  Szenario: Bereits genehmigte Bestellung zurücksetzen
    Angenommen ich bin Andi
    Und ich befinde mich im Gerätepark mit visierpflichtigen Bestellungen
    Und ich mich auf der Liste der Bestellungen befinde
    Wenn ich den Reiter "Genehmigt" einsehe
    Und ich eine bereits gehmigte Bestellung editiere
    Dann gelange ich in die Ansicht der Aushändigung
    Und ich kann Modelle hinzufügen
    Und ich kann Optionen hinzufügen
    Aber ich kann keine Gegenstände zuteilen
    Und ich kann nicht aushändigen
