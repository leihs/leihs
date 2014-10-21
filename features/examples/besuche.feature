# language: de

Funktionalität: Ausleihe

  @javascript @personas
  Szenario: Menschlich lesbare Anzeige der Differenz zum Datum
    Angenommen ich bin Pius
    Angenommen ich befinde mich auf der Seite der Besuche
    Dann wird für jeden Besuch korrekt, menschlich lesbar die Differenz zum jeweiligen Datum angezeigt

  # (FILM)
  @Upcoming
  Szenario: Visible tabs
    Given I am Andi
    When I open the tab "Contracts"
    Then I see the tabs "All", "Open" and "Closed"
    And the checkbox "To be verified" is already checked and I can uncheck

  # (FILM)
  @Upcoming
  Szenario: View contracts
      Given I am Andi
      When I open the tab "Contracts"
      Then I can view open and closed contracts
      And I can view picking lists
      And I can view value lists





