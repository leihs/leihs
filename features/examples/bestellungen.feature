# language: de

Funktionalität: Bestellungen

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

  @upcoming
  Scenario: Acknowledge order
    Given a model 'NEC 245' exists
    And 7 items of that model exist
    And there is only an order by 'Joe'
    And it asks for 5 items of model 'NEC 245'
    And Joe's email address is joe@test.ch
    And the order was submitted
    When I go to the backend
    And I go to the lending section
    And I open the tab "orders"
    Then I see the order of Joe
    And I should be able to choose "Approve"
    And I should be able to choose "Edit"
    And I should be able to choose "Reject"
    When I click "Approve"
    Then the order is approved
    And joe@test.ch receives an email
    And its subject is '[leihs] Reservation Confirmation'
    And it contains information '5 NEC 245'
    And the lending manager should be able to choose "Hand over"

  @upcoming
  Scenario: Reject order
    Given I am Pius
    Given a model 'NEC 245' exists
    And 7 items of that model exist
    And there is only an order by 'Joe'
    And it asks for 5 items of model 'NEC 245'
    And Joe's email address is joe@test.ch
    And the order was submitted
    When I go to the backend
    And I go to the lending section
    And I open the tab "orders"
    Then I see the order of Joe
    When I click "Reject"
    Then I can enter a reason why the order is rejected
    When I click "Reject" on the comment frame
    Then the order is rejected
    And joe@test.ch receives an email
    And its subject is '[leihs] Reservation Rejected'
    And it contains information '5 NEC 245' and the reason, why the order was rejected
    And the status of the order changes to "Rejected"

