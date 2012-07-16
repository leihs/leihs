Feature: Tabs Navigation

  In order to have an overview of filtered results
  As a Lending Manager
  I want to have functionalities to switch tabs
  
  Background:
    Given personas existing
      And I am "Pius"

  @javascript
  Scenario: Navigate all lending tabs
    When I open the daily view
    Then I can navigate all navigation items and nested tabs
