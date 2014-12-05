# language: de

Funktionalität: Bestellung editieren

  @javascript @personas
  Szenario: Sperrstatus des Benutzers anzeigen
    Angenommen ich bin Pius
    Wenn I navigate to the open orders
    Und ich öffne eine Bestellung von ein gesperrter Benutzer
    Dann sehe ich neben seinem Namen den Sperrstatus 'Gesperrt!'

  @javascript @personas
  Szenario: Trotzdem genehmigen für Gruppen-Verwalter unterbinden
    Angenommen ich bin Andi
    Und eine Bestellung enhält überbuchte Modelle
    Wenn ich die Bestellung editiere
    Und die Bestellung genehmige
    Dann ist es mir nicht möglich, die Genehmigung zu forcieren

  @personas
  Szenario: Keine leeren Bestellungen in der Liste der Bestellungen
    Angenommen ich bin Pius
    Und es existiert eine leere Bestellung
    Dann sehe ich diese Bestellung nicht in der Liste der Bestellungen

  @personas
  Szenario: Sichtbare Reiter
    Angenommen ich bin Andi
    Wenn ich mich auf der Liste der Bestellungen befinde
    Dann sehe ich die Reiter "Alle, Offen, Genehmigt, Abgelehnt"

  @personas
  Szenario: Definition visierpflichtige Bestellungen
    Angenommen es existiert eine visierpflichtige Bestellung
    Dann wurde diese Bestellung von einem Benutzer aus einer visierpflichtigen Gruppe erstellt
    Und diese Bestellung beinhaltet ein Modell aus einer visierpflichtigen Gruppe

  @javascript @personas
  Szenario: Alle Bestellungen anzeigen - Reiter Alle Bestellungen
    Angenommen ich bin Andi
    Und ich befinde mich im Gerätepark mit visierpflichtigen Bestellungen
    Und ich mich auf der Liste der Bestellungen befinde
    Wenn ich den Reiter "Alle" einsehe
    Dann sehe ich alle visierpflichtigen Bestellungen
    Und diese Bestellungen sind nach Erstelltdatum aufgelistet

  @javascript @browser @personas
  Szenario: Reiter Offene Bestellungen Darstellung
    Angenommen ich bin Andi
    Und ich befinde mich im Gerätepark mit visierpflichtigen Bestellungen
    Und ich mich auf der Liste der Bestellungen befinde
    Wenn ich den Reiter "Offen" einsehe
    Dann sehe ich alle offenen visierpflichtigen Bestellungen
    Und ich sehe auf der Bestellungszeile den Besteller mit Popup-Ansicht der Benutzerinformationen
    Und ich sehe auf der Bestellungszeile das Erstelldatum
    Und ich sehe auf der Bestellungszeile die Anzahl Gegenstände mit Popup-Ansicht der bestellten Gegenstände
    Und ich sehe auf der Bestellungszeile die Dauer der Bestellung
    Und ich sehe auf der Bestellungszeile den Zweck
    Und ich kann die Bestellung genehmigen
    Und ich kann die Bestellung ablehnen
    Und ich kann die Bestellung editieren
    Und ich kann keine Bestellungen aushändigen

  @javascript @browser @personas
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

  @javascript @browser @personas
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

  @javascript @personas
  Szenario: Filter zum visieren aufheben
    Angenommen ich bin Andi
    Und ich befinde mich im Gerätepark mit visierpflichtigen Bestellungen
    Und ich mich auf der Liste der Bestellungen befinde
    Und sehe ich alle visierpflichtigen Bestellungen
    Wenn ich den Filter "Zu prüfen" aufhebe
    Dann sehe ich alle Bestellungen, welche von Benutzern der visierpflichtigen Gruppen erstellt wurden

  @javascript @browser @personas
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

