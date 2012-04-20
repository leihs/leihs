Feature: Edit contract line during hand over process

  In order to edit a contract line
  As an Lending Manager
  I want to have functionalities to change a contract lines time range and quantity

  @javascript
  Scenario: Change the time range of a single contract line
    Given I am "Pius"
     When I open an hand over
      And I change a contract lines time range
     Then the time range of that contract line is changed
     
  @javascript
  Scenario: Change the quantity of a single contract line
    Given I am "Pius"
     When I open an hand over
      And I change a contract lines quantity
     Then the quantity of that contract line is changed
     
  @javascript
  Scenario: Change the time range of multiple contract lines
    Given I am "Pius"
     When I open an hand over with more then one line
      And I change the time range for multiple contract lines, envolving option and item lines
     Then the time range for that contract lines is changed
