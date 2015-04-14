
Feature: Creating software

  Background:
    Given I am Mike

  @javascript @personas @browser
  Scenario: Creating a software product
    When I add a new Software
    And I enter the following details
      | Field                | Value                                                                        |
      | Product              | Test Software                                                                |
      | Version              | Test Version                                                                 |
      | Software Information | Installationslink beachten: http://wwww.dokuwiki.ch\n\nDies ist nur ein Text |
    When there exists already a manufacturer
    Then the manufacturer can be selected from the list
    When I set a non existing manufacturer
    And I save
    Then the new software product is created and can be found in the software section
    When I edit again this software product
    Then outside the the text field, all the URLs extracted from the software information field are displayed as links
    And the new manufacturer can be found in the manufacturer list

  # marked as upcoming due to ticket 71745006
  @upcoming @javascript @personas
  Scenario: Mögliche Werte in Software-Lizenz erfassen
    Given ich befinde mich auf der Lizenz-Erstellungsseite
    Then die mögliche Werte für Aktivierungstyp sind in der folgenden Reihenfolge:
      | Aktivierungstyp |
      | Keine/r |
      | Dongle |
      | Seriennummer |
      | Lizenzserver |
      | Challenge Response/System ID |
      Then die mögliche Werte für Lizenztyp sind in der folgenden Reihenfolge:
      | Lizenztyp |
      | Frei |
      | Einzelplatz |
      | Mehrplatz |
      | Site-Lizenz |
      | Konkurrent |
    Then die mögliche Werte für Ausleihbar sind in der folgenden Reihenfolge:
      | Ausleihbar |
      | OK |
      | Nicht ausleihbar |
    Then one is able to choose for "Betriebssystem" none, one or more of the following options if form of a checkbox:
      | Betriebssystem |
      | Windows |
      | Mac OS X |
      | Linux |
      | iOS |
    Then one is able to choose for "Installation" none, one or more of the following options if form of a checkbox:
      | Citrix |
      | Lokal |
      | Web |
    Then for "Bezug" one can select one of the following options with the help of radio button
      |laufende Rechnung|
      |Investition                 |
    Then for "Lizenzablaufdatum" one can select a date
    Then for maintenance contract the available options are in the following order:
      | Nein |
      | Ja   |
    Then for "Rechnungsdatum" one can select a date
    Then for "Anschaffungswert" one can enter a number
    Then kann man als "Beschafft durch" einen Benutzer wählen
    Then for "Lieferant" one can select a supplier
    Then for "Verantwortliche Abteilung" one can select an inventory pool
    Then for "Besitzer" one can select an inventory pool
    Then for "Notiz" one can enter some text
    And die Option "Ausleihbar" ist standardmässig auf "Nicht ausleihbar" gesetzt

  @javascript @personas @upcoming
  Scenario: Software-Lizenz erfassen
    Given es existiert ein Software-Produkt
    When ich eine neue Software-Lizenz hinzufüge
    And I fill in the software
    And ein neuer Inventarcode vergeben wird
    And ich eine Seriennummer eingebe
    When I choose dongle as activation type
    Then I have to provide a dongle id
    When I choose one of the following license types
      | Mehrplatz   |
      | Konkurrent  |
      | Site-Lizenz |
    And I fill in the value of total quantity
    And I add the quantity allocations
    And if I choose none, one or more of the available options for operating system
    And if I choose none, one or more of the available options for installation
    And I choose a date for license expiration
    When I choose "Nein" for maintenance contract
    Then I am not able to choose the maintenance expiration date
    And ich kann für den Maintenance-Vertrag kein Betrag eingeben
    And ich kann für den Maintenance-Vertrag keine Währung eingeben
    When I choose "Ja" for maintenance contract
    And I choose a date for the maintenance expiration
    When I choose "Investition" as reference
    Then I have to enter a project number
    And ich die den Wert "ausleihbar" setze
    And I save
    Then sind die Informationen dieser Software-Lizenz gespeichert

  @personas @javascript @browser
  Scenario: Choosing a license for multiple/concurrent/site licenses
    Given a software product exists
    When I add a new Software License
    And I fill in all the required fields for the license
    When I choose one of the following license types
      | Multiple Workplace   |
      | Concurrent |
      | Site License |
    And I fill in total quantity with value "50"
    Then I see the remaining number of licenses shown as follows "remaining 50"
    And I add the following quantity allocations:
      | Quantity   | Text | 
      | 1        | Christina Meier| 
      | 10       | Room ITZ.Z40| 
    Then I see the remaining number of licenses shown as follows "remaining 39"
    And I add the following quantity allocations:
      | Quantity   | Text | 
      | 40       | Raum Z50 | 
    Then I see the remaining number of licenses shown as follows "remaining -1"
    When I delete the following quantity allocations:
      | Quantity   | Text | 
      | 1        | Christina Meier| 
    Then I see the remaining number of licenses shown as follows "remaining 0"

  @javascript @personas @browser
  Scenario: Software-Lizenz Anschaffungswert mit 2 Dezimalstellen erfassen
    Given a software product exists
    When I add a new Software License
    
    And I fill in all the required fields for the license
    And I fill in the field "Initial Price" with the value "1200"
    And I save
    Then "Initial Price" is saved as "1,200.00"
