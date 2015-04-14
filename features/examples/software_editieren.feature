
Feature: Editing software

  Background:
    Given I am Mike

  @javascript @personas
  Scenario: Editing a software product
    When I edit software
    And I edit the following details
      | Field                   | Value                                                           |
      | Product                | Test Software I                                                |
      | Version                | Test Version I                                                 |
      | Manufacturer | Neuer Hersteller                                               |
      | Software Information | Installationslink beachten: http://wwww.dokuwiki.ch/neue_seite |
    When I save
    And I'am on the software inventory overview
    Then the information is saved
    And the data has been updated

  #73278586
  @javascript @personas
  Scenario: Size of the software information field
    Given a software product with more than 6 text rows in field "Software Informationen" exists
    When I edit this software
    And I click in the field "Software Informationen"
    Then this field grows up till showing the complete text
    When I release the focus from this field
    Then this field shrinks back to the original size

  @javascript @personas
  Scenario: Editing a software license
    When I edit a software license with software information, quantity allocations and attachments
    Then I see the "Software Information"
    And the software information is not editable
    And the links of software information open in a new tab upon clicking
    Then I see the attachments of the software
    And I can open the attachments in a new tab
    When I select some different software
    And I enter a different serial number
    And I select a different activation type
    And I change the value of "Borrowable"
    And I change the options for operating system
    And I change the options for installation
    And I change the license expiration date
    And I change the value for maintenance contract
    And I change the value for reference
    And I change the value of the note
    And I change the value of dongle id
    And I choose one of the following license types
      | Single Workplace |
      | Concurrent       |
      | Site License     |
    And I change the value of total quantity
    And I change the quantity allocations
    #But ich kann den Inventarcode nicht ändern # really? inventory manager can change the inventory number of an item right now...
    When I save
    Then this software license's information has been updated successfully

  @javascript @personas
  Scenario: Edit software license, deleting values from the fields
    When I edit a license with set dates for maintenance expiration, license expiration and invoice date
    And I delete the data for the following fields:
      | Maintenance expiration |
      | License expiration     |
      | Invoice Date           |
    And I save
    Then I receive a notification of success
    When I edit the same license
    Then the following fields of the license are empty:
      | Maintenance expiration |
      | License expiration     |
      | Invoice Date           |
